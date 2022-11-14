//
//  File.swift
//  
//
//  
//

import Foundation
import ArgumentParser
import EASBCompiler

@main
struct EASBDriver{
    static func main(){
        print(try! Preprocessor().process([URL(fileURLWithPath: "/Users/vasik/Desktop/Untitled.asb"), URL(fileURLWithPath: "/Users/vasik/Desktop/Program.asb")]))
    }
}
