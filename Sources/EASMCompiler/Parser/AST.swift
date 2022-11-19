//
//  File.swift
//  
//
//  
//

import Foundation

public struct AST {
    
    init(from cst: CST) {
        
    }
    
    public var rootNode: Node
    
    public struct Node: CustomStringConvertible {
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
           
        }
    }

}

