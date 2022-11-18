//
//  File.swift
//  
//
//
//

import Foundation

public enum Resources{
    public static var keywords: [String] {
        let url = Bundle.module.url(forResource: "Keywords", withExtension: "txt")!
        let string = try! String(contentsOf: url)
        var components = string.components(separatedBy: "\n")
        components.removeAll { i in
            i.isEmpty
        }
        return components
    }
    
    public static var instructions: [String] {
        let url = Bundle.module.url(forResource: "Instructions", withExtension: "txt")!
        let string = try! String(contentsOf: url)
        var components = string.components(separatedBy: "\n")
        components.removeAll { i in
            i.isEmpty
        }
        return components
    }
}


