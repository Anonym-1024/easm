//
//  File.swift
//  
//
//
//

import Foundation

public typealias SourceCode = String
public class Preprocessor{
    
    public init() { }
    
    public func process(_ urls: [URL]) throws -> SourceCode{
        var files = [SourceCode]()
        for url in urls{
            if url.isFileURL && (url.pathExtension == "asb" || url.pathExtension == "ash"){
                let content = try String(contentsOf: url)
                files.append(content)
            } else {
                throw PreprocessingError.invalidFileType
            }
        }
        let sourceCode = files.joined()
        return sourceCode
    }
    
    public enum PreprocessingError: Error{
        case invalidFileType
    }
}
