//
//  File.swift
//  
//
//  
//

import Foundation

public class LexicalAnalyser{
    
    public init() { }
    
    public func analyse(sourceCode code: SourceCode) -> [Token] {
        let date = Date()
        var pos = 0
        var isString = false
        var isWhitespace = false
        var isSingleLineComment = false
        var isMultiLineComment = false
        while pos < code.count{
            let char = code[String.Index(encodedOffset: pos)]
            if !isString && !isWhitespace && !isSingleLineComment && !isMultiLineComment{
                switch char{
                
                case "\\":
                    break
                case "\"":
                    break
                case "/":
                    if code[String.Index(encodedOffset: pos + 1)] == "/"{
                        isSingleLineComment = true
                        pos += 1
                    }
                    if code[String.Index(encodedOffset: pos + 1)] == "*"{
                        isMultiLineComment = true
                        pos += 1
                    }
                    pos += 1
                    break
                default:
                    pos += 1
                    break
                }
            } else {
                switch char{
                case "\"":
                    isString = false
                    break
                case "\n":
                    isSingleLineComment = false
                    pos += 1
                    break
                case "*":
                    isMultiLineComment = false
                    pos += 1
                    break
                default:
                    print(char)
                    pos += 1
                    break
                }
            }
            
        }
        return []
    }
}
