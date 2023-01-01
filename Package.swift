// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "easm",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EASMCompiler",
            targets: ["EASMCompiler"]),
        .executable(
            name: "EASMDriver",
            targets: ["EASMDriver"]),
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EASMCompiler",
            dependencies: [],
            exclude: ["Resources/CodeExample.txt", "Resources/SyntaxHighlightingExample.pdf"],
            resources: [.process("Resources/Keywords.txt"), .process("Resources/Instructions.txt"), .process("Resources/InstructionsArgTypes.txt"), .process("Resources/Colors.xcassets"), .process("Resources/Syntax.txt"), .process("Resources/AST Structure.txt")]),
        .executableTarget(
            name: "EASMDriver",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"), .target(name: "EASMCompiler")]),
        
        .target(
            name: "BuiltinLibraries",
            dependencies: [],
            exclude: [],
            resources: [
                .process("Math/Math.asd"),
                .process("Math/Math.asm"),
                .process("Math/Math.ash"),
                .process("Standard/Standard.asd"),
                .process("Standard/Standard.asm"),
                .process("Standard/Standard.ash")
            ]),
        .testTarget(
            name: "EASMTests",
            dependencies: ["EASMCompiler"]),
    ]
)
