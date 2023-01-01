//
//  File.swift
//  
//
//  
//

import Foundation

public struct AST {
    
  
    public var rootNode: Node
    
    public struct Node: CustomStringConvertible {
        public init(children: [Node], kind: Kind, content: [String]? = nil) {
            self.children = children
            self.kind = kind
            self.content = content
        }
        
        public var description: String{
            "\(kind)\(children) \(content ?? [])"
        }
        
        public var children: [Node]
        public var kind: Kind
        public var content: [String]?
        
        public enum Kind {
            case asmFile
            case main
            case instruction
            case label
            case namespace
            case address
            case pointer
            case value
            case funcImplementation
            
            
            case ashFile
            case global
            case variable
            case arg
            case ret
            case funcDeclaration
            case charLiteral
            case intLiteral
            case varValue
        }
    }


}

public struct _AST {
    
  
    public var rootNode: Node
    
    public struct Node: CustomStringConvertible {
        public init(children: [Node], kind: Kind, content: [String]? = nil) {
            self.children = children
            self.kind = kind
            self.content = content
        }
        
        public var description: String{
            "\(kind)\(children) \(content ?? [])"
        }
        
        public var children: [Node]
        public var kind: Kind
        public var content: String?
        
        public enum Kind {
            case fileAsm
            case main
            case statements
            case statement
            case instructionStmt
            case instrArg
            case address
            case value
            case funcCallArg
            case funcCallArgs
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
            case pointer
            case varValue
            case constValue
            case funcDeclarations
            case funcDeclaration
            case funcArgs
            case funcArg
            case funcRet
            case funcDeclBody
            
            case leaf
        }
    }


}

