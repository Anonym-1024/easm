//
//  File.swift
//  
//
//
//

import Foundation
import ArgumentParser

public struct Node {
    init(children: [Node], kind: Kind, content: Token? = nil) {
        self.children = children
        self.kind = kind
        self.content = content
    }
    
    public var children: [Node]
    public var kind: Kind
    public var content: Token?
    
    public enum Kind {
        case fileAsb
        case main
        case statements
        case statement
        case instructionStmt
        case instrArg
        case address
        case pointer
        case identifier
        case lblDeclaration
        case namespace
        case funcImplementations
        case funcImplementation
        
        case fileAsh
        case globalDecl
        case varDeclarations
        case varDeclaration
        case type
        case varValue
        case literal
        case funcDeclarations
        case funcDeclaration
        case funcArgs
        case funcArg
        case funcRet
        case funcDeclBody
        
        case leaf
    }
}
