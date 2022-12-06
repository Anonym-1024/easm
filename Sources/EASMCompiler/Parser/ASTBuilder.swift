//
//  File.swift
//  
//
//  
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
    
    
    
    
    
    public func build() throws -> AST {
        switch fileType {
        case .asm:
            let node = try fileAsm(self.cst.rootNode)
            return AST(rootNode: node)
        case .ash:
            let node = try fileAsh(self.cst.rootNode)
            return AST(rootNode: node)
        }
    }
 
    // ASM File
    
    func fileAsm(_ _from: CNode) throws -> ANode {
        let d = Date()
        var from = _from
        var array = [ANode]()
        if from.children.first?.kind == .main {
            array.append(try main(from.children.first!))
            from.children.removeFirst()
        }
        
        if !from.children.isEmpty {
            guard let funcImplementations = try? funcImplementations(from.children[0]) else { throw ASTError.error }
            array.append(contentsOf: funcImplementations)
        }
        print("AST Builder: ", d.distance(to: Date()))
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
            } else if from.children.first!.children.first!.children.first!.kind == .value {
                array.append(try value(from.children.first!.children.first!.children.first!))
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
    
    func value(_ _from: CNode) throws -> ANode {
        let from = _from
        var contents = [String]()
        for i in from.children {
            if i.kind == .leaf {
                contents.append(i.content!.lexeme)
            } else {
                throw ASTError.error
            }
        }
        return ANode(children: [], kind: .value, content: contents)
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
            } else if child.kind == .funcImplementations {
                array.append(contentsOf: try funcImplementations(child))
            }
        }
        return array
    }

    
    
    
    
    // ASH File
    
    func fileAsh(_ _from: CNode) throws -> ANode {
        var from = _from
        var array = [ANode]()
        if from.children.first?.kind == .globalDecl {
            array.append(try global(from.children.first!))
            from.children.removeFirst()
        }
        
        if !from.children.isEmpty {
            guard let funcDeclarations = try? funcDeclarations(from.children[0]) else { throw ASTError.error }
            array.append(contentsOf: funcDeclarations)
        }
        
        return ANode(children: array, kind: .ashFile)
    }
    
    func global(_ _from: CNode) throws -> ANode {
        
        var from = _from
        var array = [ANode]()
        from.children.removeFirst()
        
        try array.append(contentsOf: try variables(from.children[0]))
        return ANode(children: array, kind: .global)
    }
    
    func variable(_ _from: CNode) throws -> ANode {
        var from = _from
        var array = [ANode]()
        var content = [String]()
        content.append(from.children[0].content!.lexeme)
        
        content.append(from.children[1].content!.lexeme)
        
        content.append(from.children[2].content!.lexeme)
        if from.children[4].content?.kind == .keyword {
            content.append("later")
        } else if from.children[4].children.first?.kind == .identifier{
            content.append(try identifier(from.children[4].children[0]))
        } else {
            switch from.children[4].content!.kind {
            case .charLiteral:
                array.append(charLiteral(from.children[4]))
            case .numberLiteral:
                array.append(intLiteral(from.children[4]))
            default:
                fatalError()
            }

        }
        
        return ANode(children: array, kind: .variable, content: content)
    }
    
    func varValue(_ _from: CNode) -> ANode {
        var from = _from
        return ANode(children: [], kind: .varValue, content: [from.content!.lexeme])
    }
    
    func charLiteral(_ _from: CNode) -> ANode {
        var from = _from
        
        return ANode(children: [], kind: .charLiteral, content: [from.content!.lexeme])
    }
    
    func intLiteral(_ _from: CNode) -> ANode {
        var from = _from
        
        return ANode(children: [], kind: .intLiteral, content: [from.content!.lexeme])
    }
    
    func variables(_ _from: CNode) throws -> [ANode] {
        let from = _from
        var array = [ANode]()
        for child in from.children {
            if child.kind == .varDeclaration {
                array.append(try variable(child))
            } else if child.kind == .varDeclarations {
                array.append(contentsOf: try variables(child))
            }
        }
        return array
    }
    
    func funcDeclaration(_ _from: CNode) throws -> ANode {
        var from = _from
        var array = [ANode]()
        var content = [String]()
        
        from.children.removeFirst()
        
        content.append(from.children[0].content!.lexeme)
        if from.children[1].kind == .funcArgs {
            array.append(contentsOf: args(from.children[1]))
            
            if from.children[2].kind == .funcRet {
                array.append(ret(from.children[2]))
            }
        } else {
            if from.children[1].kind == .funcRet {
                array.append(ret(from.children[1]))
            }
        }
        
        if from.children.last!.kind == .funcDeclBody {
            array.append(contentsOf: try variables(from.children.last!))
        }
        
        return ANode(children: array, kind: .funcDeclaration, content: content)
    }
    
    func funcDeclarations(_ _from: CNode) throws -> [ANode] {
        let from = _from
        var array = [ANode]()
        for child in from.children {
            if child.kind == .funcDeclaration {
                array.append(try funcDeclaration(child))
            } else if child.kind == .funcDeclarations {
                array.append(contentsOf: try funcDeclarations(child))
            }
        }
        return array
    }
    
    func arg(_ _from: CNode) -> ANode {
        var from = _from
        return ANode(children: [], kind: .arg, content: [from.children[0].content!.lexeme, from.children[1].content!.lexeme])
    }
    
    func ret(_ _from: CNode) -> ANode {
        var from = _from
        return ANode(children: [], kind: .ret, content: [from.children[0].content!.lexeme, from.children[1].content!.lexeme])
    }
    
    func args(_ _from: CNode) -> [ANode] {
        let from = _from
        var array = [ANode]()
        for child in from.children {
            if child.kind == .funcArg {
                array.append(try arg(child))
            } else if child.kind == .funcArgs {
                array.append(contentsOf: try args(child))
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
