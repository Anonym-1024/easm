//
//  File.swift
//  
//
//
//

import Foundation

public struct Token: CustomStringConvertible{
    var kind: Kind
    var lexeme: String
    public var description: String{
        "\(kind): \(lexeme)\n"
    }
    public enum Kind{
        case identifier
        case keyword
        case instruction
        case `operator`
        case punctuation
        case literal
    }
}
