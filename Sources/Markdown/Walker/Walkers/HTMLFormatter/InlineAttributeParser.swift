/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

extension HTMLFormatter {
    
    public struct InlineAttributeParser {
        
        public typealias Parser = (String) -> (any HTMLMarkup)?
        
        private let parser: Parser
        
        public init(parser: @escaping Parser) {
            self.parser = parser
        }
        
        public init<T: HTMLMarkup>(
            _ type: T.Type,
            decoder: JSONDecoder = .init()
        ) {
            self.init { attributes in
                // JSON5 parsing is available in Apple Foundation as of macOS 12 et al, or in Swift
                // Foundation as of Swift 6.0
                // Note: We don't turn on `.assumesTopLevelDictionary` to allow parsing to work on older
                // compilers and OSs. If/when Swift-Markdown assumes a minimum Swift version of 6.0, we
                // can clean this up to always use JSON5 and top-level dictionaries.
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                if #available(macOS 12, iOS 15, tvOS 15, watchOS 8, *) {
                    decoder.allowsJSON5 = true
                }
#elseif compiler(>=6.0)
                decoder.allowsJSON5 = true
#endif
                let data = InlineAttributeParser
                    .toJSON5(attributes)
                    .data(using: .utf8)
                guard let data else { return nil }
                return try? decoder.decode(type.self, from: data)
            }
        }
        
        func parse(attributes: String) -> (any HTMLMarkup)? {
            parser(attributes)
        }
        
        private static func toJSON5(_ raw: String) -> String {
//            let pairs = try! Regex<(Substring, Substring, Substring)>(
//                #"\b([A-Za-z_]\w*)\s*:\s*([A-Za-z0-9-]+)\b"#
//            )
//            return "{\(raw)}".replacing(pairs) { (match: Regex<(Substring, Substring, Substring)>.Match) in
//                let key = match.output.1
//                let value = match.output.2
//                return "\(key): '\(value)'"
//            }
            let json = "{\(raw)}"
            let pattern = #"\b([A-Za-z_]\w*)\s*:\s*([A-Za-z0-9-]+)\b"#
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            return regex.stringByReplacingMatches(
                in: json,
                options: [],
                range: NSRange(json.startIndex..<json.endIndex, in: json),
                withTemplate: "$1: '$2'"
            )
        }
    }
}
