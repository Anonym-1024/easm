//
//  File.swift
//  
//
//
//

import Foundation

public protocol Node {
    var childNodes: [Node] { get set }
    var content: String? { get }
}

extension Node {
    public mutating func addChild(_ node: Node) {
        childNodes.append(node)
    }
    
    public mutating func addChildren(_ nodes: [Node]) {
        childNodes.append(contentsOf: nodes)
    }
}

public struct LeafNode: Node {
    public var childNodes = [Node]()
    
    public var content: String?
    
    public init(_ content: String) {
        self.content = content
    }
}

public struct BranchNode: Node {
    public var childNodes = [Node]()
    
    public var content: String? = nil
    
    public init(_ nodes: [Node]) {
        self.childNodes = nodes
    }
}
