//
//  File.swift
//  
//
//  Created by Vašík Koukola on 23.11.2022.
//

import Foundation

public class ASTBuilder {
    var cst: CST
    var fileType: Parser.FileType
    
    typealias CNode = CST.Node
    typealias ANode = AST.Node
    
    public init(for cst: CST, _ fileType: Parser.FileType) {
        self.cst = cst
        self.fileType = fileType
    }
    
    // Helper methods
    
    
    
    public func build() throws -> AST {
        switch fileType {
        case .asm:
            let node = try fileAsm(self.cst.rootNode)
            return AST(rootNode: node)
        case .ash:
            fatalError()
        }
    }
 
    func fileAsm(_ _from: CNode) throws -> ANode {
        var from = _from
        var array = [ANode]()
        if from.children.first?.kind == .main {
            array.append(try main(from.children.first!))
            from.children.removeFirst()
        }
        
        
        guard let funcImplementations = try? funcImplementations(from.children[0]) else { throw ASTError.error }
        array.append(contentsOf: funcImplementations)
        
        return ANode(children: array, kind: .asmFile)
    }
    
    func main(_ _from: CNode) throws  -> ANode {
        var from = _from
        var array = [ANode]()
        from.children.removeFirst()
        
        for child in from.children {
            if child.kind == .statement {
                if let instr = try? instruction(child) {
                    array.append(instr)
                } else if let label = try? label(child) {
                    array.append(label)
                } else if let namespace = try? namespace(child) {
                    array.append(namespace)
                } else {
                    throw ASTError.error
                }
            } else if child.kind == .statements {
                array.append(contentsOf: try statements(child))
            }
        }
        return ANode(children: array, kind: .main)
    }
    
    func statements(_ _from: CNode) throws -> [ANode] {
        let from = _from
        var array = [ANode]()
        for child in from.children {
            if child.kind == .statement {
                if let instr = try? instruction(child) {
                    array.append(instr)
                } else if let label = try? label(child) {
                    array.append(label)
                } else if let namespace = try? namespace(child) {
                    array.append(namespace)
                } else {
                    throw ASTError.error
                }
            } else if child.kind == .statements {
                array.append(contentsOf: try statements(child))
            }
        }
        return array
    }
    
    func instruction(_ _from: CNode) throws -> ANode {
        var from = _from
        var contents = [String]()
        var array = [ANode]()
        contents.append(from.children[0].children.removeBeginning(1).content!.lexeme)
        if !from.children[0].children.isEmpty {
            if from.children.first!.children.first!.children.first!.kind == .address {
                array.append(try address(from.children.first!.children.first!.children.first!))
            } else if from.children.first!.children.first!.children.first!.kind == .pointer {
                array.append(try pointer(from.children.first!.children.first!.children.first!))
            }
        }
            
        return ANode(children: array, kind: .instruction, content: contents)
    }
    
    func label(_ _from: CNode) throws -> ANode {
        var from = _from
        var contents = [String]()
        var array = [ANode]()
        contents.append(from.children.removeBeginning(2).content!.lexeme)
        if !from.children.isEmpty {
            if from.children.last!.children.first!.kind == .address {
                array.append(try address(from.children.first!))
            } else {
                throw ASTError.error
            }
        }
            
        return ANode(children: array, kind: .label, content: contents)
    }
    
    func namespace(_ _from: CNode) throws -> ANode {
        var from = _from
        var contents = [String]()
        contents.append(from.children.removeBeginning(2).content!.lexeme)
        
            
        return ANode(children: [], kind: .namespace, content: contents)
    }
    
    func address(_ _from: CNode) throws -> ANode {
        let from = _from
        var contents = [String]()
        for i in from.children {
            if i.kind == .leaf {
                contents.append(i.content!.lexeme)
            } else if i.kind == .identifier{
                contents.append(try identifier(i))
            }
        }
        return ANode(children: [], kind: .address, content: contents)
    }
    
    func pointer(_ _from: CNode) throws -> ANode {
        let from = _from
        var contents = [String]()
        for i in from.children {
            if i.kind == .leaf {
                contents.append(i.content!.lexeme)
            } else if i.kind == .identifier{
                contents.append(try identifier(i))
            }
        }
        return ANode(children: [], kind: .pointer, content: contents)
    }
    
    func identifier(_ _from: CNode) throws -> String {
        let from = _from
        var array = [String]()
        for child in from.children {
            if child.kind == .leaf {
                array.append(child.content!.lexeme)
            } else if child.kind == .identifier {
                array.append(try identifier(child))
            }
        }
        return array.joined()
    }
    
    func funcImplementation(_ _from: CNode) throws -> ANode {
        let from = _from
        var array = [ANode]()
        
        for child in from.children {
            if child.kind == .statement {
                if let instr = try? instruction(child) {
                    array.append(instr)
                } else if let label = try? label(child) {
                    array.append(label)
                } else if let namespace = try? namespace(child) {
                    array.append(namespace)
                } else {
                    throw ASTError.error
                }
            } else if child.kind == .statements {
                array.append(contentsOf: try statements(child))
            }
        }
        return ANode(children: array, kind: .funcImplementation, content: nil)
    }
    
    func funcImplementations(_ _from: CNode) throws -> [ANode] {
        let from = _from
        var array = [ANode]()
        for child in from.children {
            if child.kind == .funcImplementation {
                array.append(try funcImplementation(child))
            } else if child.kind == .statements {
                array.append(contentsOf: try funcImplementations(child))
            }
        }
        return array
    }

    
    enum ASTError: Error {
        case error
    }
    
}


extension Array {
    mutating func removeBeginning(_ k: Int) -> Element {
        var el: Element?
        for _ in 0..<k {
            el = self[0]
            self.removeFirst()
        }
        return el!
    }
}
