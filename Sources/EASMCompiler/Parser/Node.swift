//
//  File.swift
//  
//
//
//

import Foundation

/*public struct Node: CustomStringConvertible {
    init(children: [Node], kind: Kind, content: Token? = nil) {
        self.children = children
        self.kind = kind
        self.content = content
    }
    
    public var description: String{
        "\(children.isEmpty ? "\(content!)" : "\(kind) \(children)")\n"
    }
    
    public var children: [Node]
    public var kind: Kind
    public var content: Token?
    
    public enum Kind {
        case fileAsm
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
    
   mutating func reducePunctuation() {
        children.removeAll { i in
            i.content?.kind == .punctuation && i.content?.lexeme != "."
        }
        
        for i in 0..<children.count {
            children[i].reducePunctuation()
        }
    }
}
*/
