//
//  File.swift
//  
//
//
//

import Foundation

public struct Token{
    var kind: Kind
    var lexeme: String

    public enum Kind{
        case identifier
        case keyword
        case instruction
        case `operator`
        case punctuation
        case literal
    }
}
