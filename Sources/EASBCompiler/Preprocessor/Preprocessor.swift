//
//  File.swift
//  
//
//
//

import Foundation

public typealias SourceCode = String

public typealias HeaderCode = String

public class Preprocessor{
    
    public init() { }
    
    public func process(_ urls: [URL]) throws -> (HeaderCode, SourceCode){
        var sources = [SourceCode]()
        var headers = [HeaderCode]()
        for url in urls{
            if url.isFileURL && (url.pathExtension == "asb") {
                let content = try String(contentsOf: url)
                sources.append(content)
            } else if url.isFileURL && (url.pathExtension == "ash") {
                let content = try String(contentsOf: url)
                headers.append(content)
            } else {
                throw PreprocessingError.invalidFileType
            }
        }
        let sourceCode = sources.joined()
        let headerCode = headers.joined()
        return (headerCode, sourceCode)
    }
    
    public enum PreprocessingError: Error{
        case invalidFileType
    }
}
