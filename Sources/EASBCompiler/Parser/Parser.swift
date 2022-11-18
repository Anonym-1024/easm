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
            return try CST(rootNode: parseFileAsb())
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
    /*func parseFileAsh() throws -> Node {
        
    }
    
    func parseGlobalDecl() throws -> Node {
        
    }
    
    func parseVarDeclarations() throws -> Node {
        
    }
    
    func parseVarDeclaration() throws -> Node {
        
    }
    
    func parseType() throws -> Node {
        
    }
    
    func parseVarValue() throws -> Node {
        
    }
    
    func parseLiteral() throws -> Node {
        
    }
    
    func parseFuncDeclarations() throws -> Node {
        
    }
    
    func parseFuncDeclaration() throws -> Node {
        
    }
    
    func parseFuncArgs() throws -> Node {
        
    }
    
    func parseFuncArg() throws -> Node {
        
    }
    
    func parseFuncRet() throws -> Node {
        
    }
    
    func parseFuncDeclBody() throws -> Node {
        
    }*/
    
    
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
    }
}
