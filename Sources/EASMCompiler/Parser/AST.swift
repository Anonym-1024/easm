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

