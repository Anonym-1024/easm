//
//  File.swift
//  
//
//  
//

import Foundation
import ArgumentParser
import EASMCompiler
import SwiftUI

@main
struct EASMDriver: ParsableCommand {
    static var configuration: CommandConfiguration{
        .init(subcommands: [EASMBuild.self], defaultSubcommand: nil)
    }
    func run() throws {
        print("Welcome to easm compiler.\n\nUse build command to build your source code.\n")
        let t = try! LexicalAnalyser(sourceCode: """
main {
    addab #78
}

func h {
    jmpe $ff
}
""").tokens()
        var f = try! Parser(tokens: t, as: .asm).parse()
        f.reducePunctuation()
        let ast = ASTBuilder(for: f, .asm)
        print(try! ast.build().rootNode.children.first!)
    }
    
}

struct EASMBuild: ParsableCommand {
    static var configuration: CommandConfiguration{
        .init(commandName: "build")
    }
    @Argument(parsing: .captureForPassthrough) var urls: [String]
    func run() throws {
        print(urls)
    }
}

/*
main {
    /*take input*/
    in
    jmpi ret; lbl in = $$
    jmp $in
    storeir $input; lbl ret = $$

    /*call div*/
    call &ret51; lbl loop = $$
    push $input
    push $five
    jmp $div
    /*output result*/
    outrn $div.return; lbl ret51 = $$
    /*call mod*/
    call &ret52
    push $input
    push $five
    jmp $mod
    /*assign result of mod to input*/
    loada $mod.return; lbl ret52  = $$
    storea $input
    /*call div*/
    call &ret21
    push $input
    push $two
    jmp $div
    /*output result*/
    outn $div.return; lbl ret21  = $$
    /*call mod*/
    call &ret22
    push $input
    push $two
    jmp $mod
    /*assign result of mod to input*/
    loada $mod.return; lbl ret22  = $$
    storea $input
    /*call div*/
    call &ret11
    push $input
    push $one
    jmp $div
    /*output result*/
    outn $div.return; lbl ret11  = $$
    /*call mod*/
    call &ret12
    push $input
    push $one
    jmp $mod
    /*assign result of mod to input*/
    loada $mod.return; lbl ret12 = $$
    storea $input




    /*call div*/
    call &reta1
    push $input
    push $ten
    jmp $div
    loada $div.return; lbl reta1 = $$
    storea $one

    /*call div*/
    call &reta2
    push $input
    push $ten
    jmp $div
    loada $div.return; lbl reta2 = $$
    storea $two

    /*call div*/
    call &reta3
    push $input
    push $ten
    jmp $div
    loada $div.return; lbl reta3 = $$
    storea $five

    loada $null
    loadb $one
    jmpe loop
    halt
}


func div(a: int, b: int) -> return: int{
loada $a
loadb $b
subab $r; lbl _sub = $$
loada $r
jmps $_end
jmp $_sub
ret; lbl _end = $$
} declaring {
    var r: int = later
}


func mod(a: int, b: int) -> return: int{
    hhhhh




}



const fivet: int = 5000
const twot: int = 2000
const onet: int = 1000
const ten: int = 10

var five: int = fivet
var two: int = twot
var one: int = onet
var input: int = later
*/
