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
        print(LexicalAnalyser().analyse(sourceCode: """
//Ahoj jak se máte

bhdiwbazf
ferg
/* multi
line
comment*/
"""))
    }
}
