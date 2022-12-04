# EASM

## Compilation process

*Source code* -> **Preprocessor** -> **Lexer** -> *Token stream* -> **Parser** -> *AST* -> **Semantic analysis** -> **Code generation** -> *Machine code*


### Preprocessor
Takes all files to compile and merges them into single implementation and header files. Imports library dependencies declared in `.asd` file.


### Lexer
Creates a token stream from the preprocessor output. Each token contains information about its content and kind.

Token is defined as: 
```
struct Token{
    var kind: Kind
    var lexeme: String
}
```

Token kind is defined as: 
```
enum Kind {
    case identifier
    case keyword
    case instruction
    case operator
    case punctuation
    case numberLiteral
    case charLiteral
}
```


### Parser
EASB uses a simple descent recursive parser. 

It has two phases:

1. Syntax analysis
    - Declared in [Parser.swift](Sources/EASMCompiler/Parser/Parser.swift)
    - Checks context-free-grammar declared in [Syntax.txt](Sources/EASMCompiler/Resources/Syntax.txt)
    - Outputs CST
2. AST Building
    - Builds AST from CST
    - Uses rules declared in [AST Structure.txt](<Sources/EASMCompiler/Resources/AST Structure.txt>)


### Semantic analysis
Checks that:

- No variable is declared twice within scope
- Instruction arguments have the right type


### Code generation
Processes AST and generates executable machine code.



## [Language guide](<Language guide.md>)
