/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2023 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import Foundation

public protocol HTMLMarkup: Decodable {
    var htmlTag: String? { get }

    var tagAttributes: String { get }
}

extension Dictionary: HTMLMarkup where Key == String, Value == String {
    public var htmlTag: String? {
        self["htmltag"]
    }
    
    public var tagAttributes: String {
        filter {
            $0.key != "htmltag"
        }
        .reduce(into: "") { result, pair in
            result += " \(pair.key)=\"\(pair.value)\""
        }
    }
}
