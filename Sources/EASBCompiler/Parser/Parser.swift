//
//  File.swift
//  
//
//
//

import Foundation

public class Parser {
    
    public enum FileType {
        case asb
        case ash
    }
    
    public init(tokens: [Token], as fileType: FileType) {
        self.tokens = tokens
        self.fileType = fileType
        self.pos = 0
    }
    
    var tokens: [Token]
    var fileType: FileType
    var pos: Int
    
    //Helper methods
    func currentToken() -> Token {
        tokens[pos]
    }
    
    func popToken() -> Token {
        let token = tokens[pos]
        if pos < tokens.count - 1{
            pos += 1
        }
        return token
    }
    
    func advance(_ by: Int = 1) {
        self.pos += by
    }
    
    func conforms(to kind: Token.Kind) -> Bool {
        tokens[pos].kind == kind
    }
    
    func conforms(to value: String) -> Bool {
        tokens[pos].lexeme == value
    }
    
    
    
    
    
    //ASB files
    public func parse() throws -> CST {
        switch fileType {
        case .asb:
            return try CST(rootNode: parseFileAsb())
        case .ash:
            return try CST(rootNode: parseFileAsh())
        }
    }
    
    func parseFileAsb() throws -> Node {
        let mainNode = try parseMain()
        if let funcImplementationsNode = try? parseFuncImplementations() {
            return Node(children: [mainNode, funcImplementationsNode], kind: .fileAsb)
        } else {
            return Node(children: [mainNode], kind: .fileAsb)
        }
    }
    
    func parseMain() throws -> Node {
        let date = Date()
        guard conforms(to: "main") else { throw ParserError.expectedKeyword("main")}
        let mainKeywordNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: "{") else { throw ParserError.expectedPunctuation("{")}
        let lBraceNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        let statementsNode = try parseStatements()
        print(pos)
        guard conforms(to: "}") else { throw ParserError.expectedPunctuation("}")}
        let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
        if pos < tokens.count - 1 {
            
        }
        print(date.distance(to: Date()))
        return Node(children: [mainKeywordNode, lBraceNode, statementsNode, rBraceNode], kind: .main)
    }
    
    func parseStatements() throws -> Node {
        let statementNode = try parseStatement()
        if let statementsNode = try? parseStatements() {
            return Node(children: [statementNode, statementsNode], kind: .statements)
        } else {
            return Node(children: [statementNode], kind: .statements)
        }
    }
    
    func parseStatement() throws -> Node {
        if let instructionStmtNode = try? parseInstructionStmt() {
            return Node(children: [instructionStmtNode], kind: .statement)
        } else if let lblDeclarationNode = try? parseLblDeclaration() {
            return Node(children: [lblDeclarationNode], kind: .statement)
        } else if let namespaceNode = try? parseNamespace() {
            return Node(children: [namespaceNode], kind: .statement)
        } else {
            throw ParserError.invalidStatement
        }
    }
    
    func parseInstructionStmt() throws -> Node {
        guard conforms(to: .instruction) else { throw ParserError.expectedInstruction}
        let instructionNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        if let instrArgNode = try? parseInstrArg() {
            if conforms(to: ";") {
                advance()
            }
            return Node(children: [instructionNode, instrArgNode], kind: .instructionStmt)
        } else {
            if conforms(to: ";") {
                advance()
            }
            return Node(children: [instructionNode], kind: .instructionStmt)
        }
    }
    
    func parseInstrArg() throws -> Node {
        if let addressNode = try? parseAddress() {
            return Node(children: [addressNode], kind: .instrArg)
        } else if let pointerNode = try? parsePointer() {
            return Node(children: [pointerNode], kind: .instrArg)
        }  else {
            throw ParserError.expectedArgument
        }
    }
    
    func parseAddress() throws -> Node {
        if conforms(to: " #") {
            let numberSignNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            guard conforms(to: .numberLiteral) else { throw ParserError.invalidAddress}
            let numberLiteralNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [numberSignNode, numberLiteralNode], kind: .address)
        } else if conforms(to: " $") {
            let dollarSignNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            if let identifierNode = try? parseIdentifier() {
                return Node(children: [dollarSignNode, identifierNode], kind: .address)
            } else if conforms(to: "null") {
                let nullNode = Node(children: [], kind: .leaf, content: popToken())
                
                
                return Node(children: [dollarSignNode, nullNode], kind: .address)
            } else {
                throw ParserError.invalidAddress
            }
        } else if conforms(to: "$$") {
            let dollarNode = Node(children: [], kind: .leaf, content: popToken())
            
            return Node(children: [dollarNode], kind: .address)
        } else {
            throw ParserError.invalidAddress
        }
    }
    
    func parsePointer() throws -> Node {
        
        if conforms(to: " &") {
            let ampersandNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            if conforms(to: .numberLiteral) {
                let numberLiteralNode = Node(children: [], kind: .leaf, content: popToken())
                
                
                return Node(children: [ampersandNode, numberLiteralNode], kind: .pointer)
            } else if let identifierNode = try? parseIdentifier() {
                return Node(children: [ampersandNode, identifierNode], kind: .pointer)
            } else if conforms(to: "null") {
                let nullNode = Node(children: [], kind: .leaf, content: popToken())
                
                
                return Node(children: [ampersandNode, nullNode], kind: .pointer)
            } else {
                throw ParserError.invalidPointer
            }
        } else {
            throw ParserError.invalidPointer
        }
    }
    
    func parseIdentifier() throws -> Node {
        guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        if conforms(to: ".") {
            let dotNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            let nextIdentifierNode = try parseIdentifier()
            return Node(children: [identifierNode, dotNode, nextIdentifierNode], kind: .identifier)
        }
        
        return Node(children: [identifierNode], kind: .identifier)
    }
    
    func parseLblDeclaration() throws -> Node {
        guard conforms(to: "lbl") else { throw ParserError.invalidLabelDeclaration}
        let lblNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: .identifier) else { throw ParserError.invalidLabelDeclaration}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: " = ") else { throw ParserError.invalidLabelDeclaration}
        let equalSignNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        let addressNode = try parseAddress()
        
        return Node(children: [lblNode, identifierNode, equalSignNode, addressNode], kind: .lblDeclaration)
    }
    
    func parseNamespace() throws -> Node {
        guard conforms(to: "---") else { throw ParserError.invalidNamespaceDeclaration}
        let startNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: .identifier) else { throw ParserError.invalidNamespaceDeclaration}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: "---") else { throw ParserError.invalidNamespaceDeclaration}
        let endNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        return Node(children: [startNode, identifierNode, endNode], kind: .namespace)
    }
    
    func parseFuncImplementations() throws -> Node {
        let funcImplementationNode = try parseFuncImplementation()
        
        if let funcImplementationsNode = try? parseFuncImplementations() {
            return Node(children: [funcImplementationNode, funcImplementationsNode], kind: .funcImplementations)
        } else {
            return Node(children: [funcImplementationNode], kind: .funcImplementations)
        }
    }
    
    func parseFuncImplementation() throws -> Node {
        guard conforms(to: "func") else { throw ParserError.invalidFunctionImplementation}
        let funcNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: .identifier) else { throw ParserError.invalidFunctionImplementation}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: "{") else { throw ParserError.invalidFunctionImplementation}
        let lBraceNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        let statementsNode = try parseStatements()
        
        guard conforms(to: "}") else { throw ParserError.invalidFunctionImplementation}
        let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        return Node(children: [funcNode, identifierNode, lBraceNode, statementsNode, rBraceNode], kind: .funcImplementation)
    }
    
    
    

    
    
    
    //ASH files
    func parseFileAsh() throws -> Node {
        var children = [Node]()
        
        if let globalDeclNode = try? parseGlobalDecl() {
            children.append(globalDeclNode)
        }
        if let funcDeclarationsNode = try? parseFuncDeclarations() {
            children.append(funcDeclarationsNode)
        }
        
        return Node(children: children, kind: .fileAsh)
    }
    
    func parseGlobalDecl() throws -> Node {
        guard conforms(to: "global") else { throw ParserError.expectedKeyword("global") }
        let globalNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: "{") else { throw ParserError.expectedKeyword("global") }
        let lBracketNode = Node(children: [], kind: .leaf, content: popToken())
        
        let varDeclarationsNode = try parseVarDeclarations()
        
        guard conforms(to: "}") else { throw ParserError.expectedKeyword("global") }
        let rBracketNode = Node(children: [], kind: .leaf, content: popToken())
        
        return Node(children: [globalNode, lBracketNode, varDeclarationsNode, rBracketNode], kind: .globalDecl)
    }
    
    func parseVarDeclarations() throws -> Node {
        let varDeclarationNode = try parseVarDeclaration()
        if let varDeclarationsNode = try? parseVarDeclarations() {
            return Node(children: [varDeclarationNode, varDeclarationsNode], kind: .varDeclarations)
        } else {
            return Node(children: [varDeclarationNode], kind: .varDeclarations)
        }
    }
    
    func parseVarDeclaration() throws -> Node {
        if conforms(to: "var") {
            let varNode = Node(children: [], kind: .leaf, content: popToken())
            
            guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier }
            let identifierNode = Node(children: [], kind: .leaf, content: popToken())
            
            guard conforms(to: ":") else { throw ParserError.expectedTypeDeclaration }
            let colonNode = Node(children: [], kind: .leaf, content: popToken())
            
            let typeNode = try parseType()
            
            guard conforms(to: " = ") else { throw ParserError.expectedPunctuation("=") }
            let equalSignNode = Node(children: [], kind: .leaf, content: popToken())
            
            let varValueNode = try parseVarValue()
            
            return Node(children: [varNode, identifierNode, colonNode, typeNode, equalSignNode, varValueNode], kind: .varDeclaration)
            
        } else if conforms(to: "const") {
            let constNode = Node(children: [], kind: .leaf, content: popToken())
            
            guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier }
            let identifierNode = Node(children: [], kind: .leaf, content: popToken())
            
            guard conforms(to: ":") else { throw ParserError.expectedTypeDeclaration }
            let colonNode = Node(children: [], kind: .leaf, content: popToken())
            
            let typeNode = try parseType()
            
            guard conforms(to: " = ") else { throw ParserError.expectedPunctuation("=") }
            let equalSignNode = Node(children: [], kind: .leaf, content: popToken())
            
            let literalNode = try parseLiteral()
            
            return Node(children: [constNode, identifierNode, colonNode, typeNode, equalSignNode, literalNode], kind: .varDeclaration)
        } else {
            throw ParserError.expectedKeyword("var/const")
        }
    }
    
    func parseType() throws -> Node {
        if conforms(to: "int") || conforms(to: "char") {
            return Node(children: [], kind: .leaf, content: popToken())
        } else {
            throw ParserError.invalidType
        }
    }
    
    func parseVarValue() throws -> Node {
        if conforms(to: "later") || conforms(to: .identifier) {
            return Node(children: [], kind: .leaf, content: popToken())
        } else {
            throw ParserError.invalidType
        }
    }
    
    func parseLiteral() throws -> Node {
        if conforms(to: .charLiteral) || conforms(to: .numberLiteral) {
            return Node(children: [], kind: .leaf, content: popToken())
        } else {
            throw ParserError.invalidType
        }
    }
    
    func parseFuncDeclarations() throws -> Node {
        let funcDeclarationNode = try parseFuncDeclaration()
        if let funcDeclarationsNode = try? parseFuncDeclarations() {
            return Node(children: [funcDeclarationNode, funcDeclarationsNode], kind: .funcDeclarations)
        } else {
            return Node(children: [funcDeclarationNode], kind: .funcDeclarations)
        }
    }
    
    func parseFuncDeclaration() throws -> Node {
        guard conforms(to: "func") else { throw ParserError.expectedKeyword("func")}
        let funcNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier }
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: "(") else { throw ParserError.expectedPunctuation("(") }
        let lParNode = Node(children: [], kind: .leaf, content: popToken())
        
        let funcArgsNode = try parseFuncArgs()
        
        guard conforms(to: ")") else { throw ParserError.expectedPunctuation(")") }
        let rParNode = Node(children: [], kind: .leaf, content: popToken())
        
        var optNodes = [Node]()
        if let funcRetNode = try? parseFuncRet() {
            optNodes.append(funcRetNode)
        }
        if let funcDeclBody = try? parseFuncDeclBody() {
            optNodes.append(funcDeclBody)
        }
        
        return Node(children: [funcNode, identifierNode, lParNode, funcArgsNode, rParNode] + optNodes, kind: .funcDeclaration)
    }
    
    func parseFuncArgs() throws -> Node {
        let funcArgNode = try parseFuncArg()
        
        if conforms(to: ",") {
            let commaNode = Node(children: [], kind: .leaf, content: popToken())
            
            let funcArgsNode = try parseFuncArgs()
            
            return Node(children: [funcArgNode, commaNode, funcArgsNode], kind: .funcArgs)
        } else {
            return Node(children: [funcArgNode], kind: .funcArgs)
        }
    }
    
    func parseFuncArg() throws -> Node {
        guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: ":") else { throw ParserError.expectedPunctuation(":")}
        let colonNode = Node(children: [], kind: .leaf, content: popToken())
        
        let typeNode = try parseType()
        
        return Node(children: [identifierNode, colonNode, typeNode], kind: .funcArg)
    }
    
    func parseFuncRet() throws -> Node {
        guard conforms(to: "->") else { throw ParserError.expectedIdentifier}
        let arrowNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: ":") else { throw ParserError.expectedPunctuation(":")}
        let colonNode = Node(children: [], kind: .leaf, content: popToken())
        
        let typeNode = try parseType()
        
        return Node(children: [arrowNode, identifierNode, colonNode, typeNode], kind: .funcRet)
    }
    
    func parseFuncDeclBody() throws -> Node {
        guard conforms(to: "{") else { throw ParserError.expectedPunctuation("{")}
        let lBracketNode = Node(children: [], kind: .leaf, content: popToken())
        
        let varDeclarationsNode = try parseVarDeclarations()
        
        guard conforms(to: "}") else { throw ParserError.expectedPunctuation("}")}
        let rBracketNode = Node(children: [], kind: .leaf, content: popToken())
        
        return Node(children: [lBracketNode, varDeclarationsNode, rBracketNode], kind: .funcDeclBody)
    }
    
    
    enum ParserError: Error {
        case expectedKeyword(String)
        case expectedPunctuation(String)
        case invalidStatement
        case expectedIdentifier
        case expectedInstruction
        case expectedArgument
        case invalidAddress
        case invalidPointer
        case invalidLabelDeclaration
        case invalidNamespaceDeclaration
        case invalidFunctionImplementation
        case expectedTypeDeclaration
        case invalidType
    }
    
}
