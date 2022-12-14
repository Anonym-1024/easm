//
//  File.swift
//  
//
//
//

import Foundation

public class Parser {
    
    typealias Node = CST.Node
    
    public enum FileType {
        case asm
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
        return tokens[pos]
    }
    
    func popToken() -> Token {
        let token = tokens[pos]
        if pos < tokens.count - 1{
            pos += 1
        }
        while pos < tokens.count - 1 && tokens[pos].lexeme == "\n" {
            pos += 1
        }
        return token
    }
    
    func wasTerminatedByNewLine() -> Bool {
        tokens[previousTokenPos() + 1].lexeme == "\n"
    }
    
    func previousTokenPos() -> Int {
        var _pos = pos - 1
        while tokens[_pos].lexeme == "\n" {
            _pos -= 1
        }
        return _pos
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
    
    
    
    
    
    //ASM files
    public func parse() throws -> CST {
        switch fileType {
        case .asm:
            return try CST(rootNode: parseFileAsm())
        case .ash:
            return try CST(rootNode: parseFileAsh())
        }
    }
    
    func parseFileAsm() throws -> Node {
        let d = Date()
        var children = [Node]()
        
        if let mainNode = try? parseMain() {
            children.append(mainNode)
        }
        if let funcImplementationsNode = try? parseFuncImplementations() {
            children.append(funcImplementationsNode)
        }
        print("Parser: ", d.distance(to: Date()))
        return Node(children: children, kind: .fileAsh)
    }
    
    func parseMain() throws -> Node {
        guard conforms(to: "main") else { throw ParserError.expectedKeyword("main")}
        let mainKeywordNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: "{") else { throw ParserError.expectedPunctuation("{")}
        let lBraceNode = Node(children: [], kind: .leaf, content: popToken())
        
        let statementsNode = try parseStatements()
        guard conforms(to: "}") else { throw ParserError.expectedPunctuation("}")}
        let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
        if pos < tokens.count - 1 {
            
        }
        return Node(children: [mainKeywordNode, lBraceNode, statementsNode, rBraceNode], kind: .main)
    }
    
    func parseStatements() throws -> Node {
        let statementNode = try parseStatement()
        
        let terminatorNode = try parseTerminator()
        
        if let statementsNode = try? parseStatements() {
            return Node(children: [statementNode, terminatorNode, statementsNode], kind: .statements)
        } else {
            return Node(children: [statementNode, terminatorNode], kind: .statements)
        }
    }
    
    func parseStatement() throws -> Node {
        if let instructionStmtNode = try? parseInstructionStmt() {
            return Node(children: [instructionStmtNode], kind: .statement)
        } else if let lblDeclarationNode = try? parseLblDeclaration() {
            return Node(children: [lblDeclarationNode], kind: .statement)
        } else if let namespaceNode = try? parseNamespace() {
            return Node(children: [namespaceNode], kind: .statement)
        } else if let callNode = try? parseCall() {
            return Node(children: [callNode], kind: .statement)
        } else if let syscallNode = try? parseSyscall() {
            return Node(children: [syscallNode], kind: .statement)
        } else {
            throw ParserError.invalidStatement
        }
    }
    
    func parseTerminator() throws -> Node {
        if conforms(to: ";") {
            return Node(children: [], kind: .leaf, content: popToken())
        } else if wasTerminatedByNewLine() {
            return Node(children: [], kind: .leaf, content: Token(kind: .punctuation, lexeme: "\n"))
        } else if conforms(to: "}") {
            return Node(children: [], kind: .leaf, content: currentToken())
        } else {
            throw ParserError.invalidStatement
        }
    }
    
    func parseInstructionStmt() throws -> Node {
        guard conforms(to: .instruction) else { throw ParserError.expectedInstruction}
        let instructionNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        if let instrArgNode = try? parseInstrArg() {
            return Node(children: [instructionNode, instrArgNode], kind: .instructionStmt)
        } else {
            return Node(children: [instructionNode], kind: .instructionStmt)
        }
    }
    
    func parseInstrArg() throws -> Node {
        if let addressNode = try? parseAddress() {
            return Node(children: [addressNode], kind: .instrArg)
        } else if let valueNode = try? parseValue() {
            return Node(children: [valueNode], kind: .instrArg)
        } else {
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
    
    
    func parseValue() throws -> Node {
        
        if conforms(to: " @") {
            let atNode = Node(children: [], kind: .leaf, content: popToken())
            
            if conforms(to: .numberLiteral) {
                let numberLiteralNode = Node(children: [], kind: .leaf, content: popToken())
                return Node(children: [atNode, numberLiteralNode], kind: .value)
            } else if conforms(to: .charLiteral){
                let charLiteralNode = Node(children: [], kind: .leaf, content: popToken())
                return Node(children: [atNode, charLiteralNode], kind: .value)
            } else {
                throw ParserError.invalidValue
            }
            
            
            
        } else {
            throw ParserError.invalidValue
        }
    }
    
    func parseCall() throws -> Node {
        guard conforms(to: "call") else { throw ParserError.invalidCall}
        let callNode = Node(children: [], kind: .leaf, content: popToken())
        
    
        let identifierNode = try parseIdentifier()
        
        
        guard conforms(to: "(") else { throw ParserError.invalidCall}
        let lBraceNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        if let funcCallArgsNode = try? parseFuncCallArgs() {
            guard conforms(to: ")") else { throw ParserError.invalidCall}
            let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [callNode, identifierNode, lBraceNode, funcCallArgsNode, rBraceNode], kind: .funcImplementation)
        } else {
            guard conforms(to: ")") else { throw ParserError.invalidCall}
            let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [callNode, identifierNode, lBraceNode, rBraceNode], kind: .funcImplementation)
        }
    }
    
    func parseSyscall() throws -> Node {
        guard conforms(to: "syscall") else { throw ParserError.invalidCall}
        let syscallNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: .identifier) else { throw ParserError.invalidCall}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        guard conforms(to: "(") else { throw ParserError.invalidCall}
        let lBraceNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        if let funcCallArgNode = try? parseFuncCallArg() {
            guard conforms(to: ")") else { throw ParserError.invalidCall}
            let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [syscallNode, identifierNode, lBraceNode, funcCallArgNode, rBraceNode], kind: .funcImplementation)
        } else {
            guard conforms(to: ")") else { throw ParserError.invalidCall}
            let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [syscallNode, identifierNode, lBraceNode, rBraceNode], kind: .funcImplementation)
        }
    }
    
    func parseFuncCallArgs() throws -> Node {
        let funcCallArgNode = try parseFuncCallArg()
        
        if conforms(to: ",") {
            let commaNode = Node(children: [], kind: .leaf, content: popToken())
            
            let funcCallArgsNode = try parseFuncCallArgs()
            
            return Node(children: [funcCallArgNode, commaNode, funcCallArgsNode], kind: .funcCallArgs)
        } else {
            return Node(children: [funcCallArgNode], kind: .funcArgs)
        }
    }
    
    func parseFuncCallArg() throws -> Node {
        guard conforms(to: .identifier) else { throw ParserError.expectedIdentifier}
        let identifierNode = Node(children: [], kind: .leaf, content: popToken())
        
        guard conforms(to: ":") else { throw ParserError.expectedPunctuation(":")}
        let colonNode = Node(children: [], kind: .leaf, content: popToken())
        
        let instrArgNode = try parseInstrArg()
        
        return Node(children: [identifierNode, colonNode, instrArgNode], kind: .funcCallArg)
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
        
        
        if let statementsNode = try? parseStatements() {
            guard conforms(to: "}") else { throw ParserError.invalidFunctionImplementation}
            let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [funcNode, identifierNode, lBraceNode, statementsNode, rBraceNode], kind: .funcImplementation)
        } else {
            guard conforms(to: "}") else { throw ParserError.invalidFunctionImplementation}
            let rBraceNode = Node(children: [], kind: .leaf, content: popToken())
            
            
            return Node(children: [funcNode, identifierNode, lBraceNode, rBraceNode], kind: .funcImplementation)
        }
        
        
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
            
        
            guard conforms(to: ":") else { throw ParserError.invalidType }
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
            
            let constValueNode = try parseConstValue()
            
            return Node(children: [constNode, identifierNode, colonNode, typeNode, equalSignNode, constValueNode], kind: .varDeclaration)
        } else {
            throw ParserError.expectedKeyword("var/const")
        }
    }
    
    func parseType() throws -> Node {
        if conforms(to: "int") || conforms(to: "char") || conforms(to: "any") {
            return Node(children: [], kind: .leaf, content: popToken())
        } else if conforms(to: "*"){
            var asterisks = [Character]()
            while currentToken().lexeme == "*" {
                asterisks.append(Character(popToken().lexeme))
            }
            if conforms(to: "int") || conforms(to: "char") {
                let popped = popToken()
                return Node(children: [], kind: .leaf, content: Token(kind: popped.kind, lexeme: String(asterisks) + popped.lexeme))
            } else {
                throw ParserError.invalidType
            }
        } else {
            throw ParserError.invalidType
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
    
    func parseVarValue() throws -> Node {
        if conforms(to: "later") {
            let laterNode = Node(children: [], kind: .leaf, content: popToken())
            return Node(children: [laterNode], kind: .varValue)
        
        } else if let identifierNode = try? parseIdentifier(){
            return Node(children: [identifierNode], kind: .varValue)
        } else if let valueNode = try? parseValue(){
            return Node(children: [valueNode], kind: .varValue)
        } else if let pointerNode = try? parsePointer(){
            return Node(children: [pointerNode], kind: .varValue)
        } else {
            throw ParserError.invalidType
        }
    }
    
    func parseConstValue() throws -> Node {
        if conforms(to: .charLiteral) || conforms(to: .numberLiteral) {
            let literalNode = Node(children: [], kind: .leaf, content: popToken())
            return Node(children: [literalNode], kind: .constValue)
        } else if let pointerNode = try? parsePointer(){
            return Node(children: [pointerNode], kind: .constValue)
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
        var argsNode = [Node]()
        if let funcArgsNode = try? parseFuncArgs() {
            argsNode.append(funcArgsNode)
        }
        guard conforms(to: ")") else { throw ParserError.expectedPunctuation(")") }
        let rParNode = Node(children: [], kind: .leaf, content: popToken())
        
        var optNodes = [Node]()
        
        if let funcRetNode = try? parseFuncRet() {
            optNodes.append(funcRetNode)
        }
        
        if let funcDeclBody = try? parseFuncDeclBody() {
            optNodes.append(funcDeclBody)
        }
        
        guard conforms(to: "{") else { throw ParserError.expectedPunctuation("{")}
        let lBracketNode = Node(children: [], kind: .leaf, content: popToken())
        
        optNodes.append(lBracketNode)
        
        if let varDeclarationsNode = try? parseVarDeclarations() {
            optNodes.append(varDeclarationsNode)
        }
        
        guard conforms(to: "}") else { throw ParserError.expectedPunctuation("}")}
        let rBracketNode = Node(children: [], kind: .leaf, content: popToken())
        
        
        return Node(children: [funcNode, identifierNode, lParNode] + argsNode + [rParNode] + optNodes + [rBracketNode], kind: .funcDeclaration)
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
        case invalidValue
        case invalidCall
    }
    
}
