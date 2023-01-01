//
//  File.swift
//  
//
//
//

import Foundation

class _ASTBuilder {
    var cst: CST
    var fileType: Parser.FileType
    
    typealias CNode = CST.Node
    typealias ANode = _AST.Node
    
    public init(for cst: CST, _ fileType: Parser.FileType) {
        self.cst = cst
        self.fileType = fileType
    }
    
    
    
    
    
    public func build() throws -> _AST {
        switch fileType {
        case .asm:
            let node = try fileAsm(self.cst.rootNode)
            return _AST(rootNode: node)
        case .ash:
            let node = try fileAsh(self.cst.rootNode)
            return _AST(rootNode: node)
        }
    }
    
    
    
    public func buildFileAsm(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
        
        if from.children.first?.kind == .main {
            children.append(buildMain(from.children.first!))
            from.children.removeFirst()
        }
        
        if from.children.first?.kind == .funcImplementations {
            children.append(buildFuncImplementations(from.children.first!))
            from.children.removeFirst()
        }
        
        return ANode(children: children, kind: .fileAsm, content: content)
    }
    
    public func buildMain(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
        
        from.children.removeFirst(2)
        from.children.removeLast()
        if from.children.first?.kind == .statements {
            children.append(buildStatements(from.children.first!))
        }
        
        return ANode(children: children, kind: .main, content: content)
    }
    
    public func buildStatements(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
        
        children.append(buildStatement(from.children.first!))
        if from.children.count == 3{
            from.children.remove(at: 1)
            children.append(contentsOf: buildStatements(from[1]).children)
        }
        return ANode(children: children, kind: .statements, content: content)
    }
    
    public func buildStatement(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
        
        switch from.children.first!.kind {
        case .instructionStmt:
            children.append(buildInstructionStmt(from.children.first!))
        case .lblDeclaration:
            children.append(buildlblDeclaration(from.children.first!))
        case .namespace:
            children.append(buildNamespace(from.children.first!))
        case .syscall:
            children.append(buildSyscall(from.children.first!))
        case .call:
            children.append(buildCall(from.children.first!))
        default:
            break
        }
    }
    
    public func buildInstructionStmt(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildInstrArg(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildAddress(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildValue(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildCall(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildSyscall(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildFuncCallArgs(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildFuncCallArg(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildIdentifier(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildLblDeclaration(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildNamespace(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildFuncImplementations(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    public func buildFuncImplementation(_ _from: CNode) throws -> ANode {
        var from = _from
        var children = [ANode]()
        var content: String?
    }
    
    
    
    
    
    
    
    
    public func buildFileAsh(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildGlobalDecl(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildVarDeclarations(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildVarDeclaration(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildType(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildPointer(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildVarValue(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildConstValue(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildFuncDeclarations(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildFuncDeclaration(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildFuncArgs(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildFuncArg(_ from: CNode) throws -> ANode {
        
    }
    
    public func buildFuncRet(_ from: CNode) throws -> ANode {
        
    }
}
