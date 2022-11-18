//
//  File.swift
//  
//
//  
//

import Foundation

public typealias LexerInput = String

public class LexicalAnalyser{
    
    var chars: [Character]
    
    var pos: Int
    
    public init(sourceCode: SourceCode) {
        self.chars = Array(sourceCode)
        self.pos = 0
    }
    
    public func tokens() throws -> [Token] {
        var tokens = [Token]()
        while pos < chars.count {
            let char = chars[pos]
            switch char {
                
            //Whitespaces
            case " ", "\n":
                pos += 1
                
            //Comments
            case "/":
                try handleComment()
                
            //Character
            case "\"":
                tokens.append(try handleCharLiteral())
                
            //Number
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                tokens.append(handleNumberLiteral())
                
            //Regular words
            case "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z":
                tokens.append(handleWord())
                
            //Operator
            case "=", "#", "$", "&":
                tokens.append(try handleOperator())
                
            //Punctuation
            case "{", "}", "(", ")", ",", ".", ";", ":":
                tokens.append(handlePunctuation())
                
            case "-":
                if chars[pos + 1] == ">" {
                    tokens.append(handlePunctuation())
                } else if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(chars[pos + 1]) {
                    tokens.append(handleNumberLiteral())
                } else {
                    tokens.append(try handleOperator())
                }
                    
            default:
                throw LexerError.invalidCharacter
            }
        }
        return tokens
    }
    
    func handleComment() throws {
        if chars[pos + 1] == "/" {
            while chars[pos] != "\n"{
                pos += 1
            }
            pos += 1
        } else if chars[pos + 1] == "*" {
            pos += 2
            while !((chars[pos] == "*" && chars[pos + 1] == "/") || pos == chars.count - 1){
                pos += 1
            }
            pos += 2
            
        } else {
            throw LexerError.invalidCharacter
        }
    }
    
    func handleCharLiteral() throws -> Token{
        if ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(chars[pos + 1]) && chars[pos + 2] == "\"" {
            let token = Token(kind: .charLiteral, lexeme: String(["\"", chars[pos + 1], "\""]))
            pos += 3
            return token
        } else {
            throw LexerError.invalidCharacterLiteral
        }
    }
    
    func handleNumberLiteral() -> Token{
        var num = String(chars[pos])
        pos += 1
        
        while ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(chars[pos]){
            num.append(chars[pos])
            pos += 1
        }
        return Token(kind: .numberLiteral, lexeme: num)
    }
    
    func handleWord() -> Token {
        var word = String(chars[pos])
        pos += 1
        
        while ["_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(chars[pos]){
            word.append(chars[pos])
            pos += 1
        }
        if Resources.keywords.contains(word) {
            return Token(kind: .keyword, lexeme: word)
        } else if Resources.instructions.contains(word) {
            return Token(kind: .instruction, lexeme: word)
        } else {
            return Token(kind: .identifier, lexeme: word)
        }
    }
    
    func handleOperator() throws -> Token {
        if chars[pos] == "$" && chars[pos + 1] == "$" {
            let token = Token(kind: .operator, lexeme: "$$")
            pos += 2
            return token
        } else if chars[pos...(pos + 2)] == ["-", "-", "-"]{
            let token = Token(kind: .operator, lexeme: "---")
            pos += 3
            return token
        } else if chars[pos - 1] == " " && chars[pos + 1] == " " {
            let token = Token(kind: .operator, lexeme: String(chars[(pos - 1)...(pos + 1)]))
            pos += 2
            return token
        } else if chars[pos - 1] == " " {
            let token = Token(kind: .operator, lexeme: String(chars[(pos - 1)...pos]))
            pos += 1
            return token
        } else {
            throw LexerError.invalidOperator
        }
    }
    
    func handlePunctuation() -> Token {
        var token: Token
        if chars[pos] == "-", chars[pos + 1] == ">" {
             token = Token(kind: .punctuation, lexeme: "->")
            pos += 1
        } else {
            token = Token(kind: .punctuation, lexeme: String(chars[pos]))
        }
        
        pos += 1
        return token
    }
    
    enum LexerError: Error{
        case invalidCharacter
        case invalidOperator
        case invalidCharacterLiteral
    }
}
