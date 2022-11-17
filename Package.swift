// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "easb",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EASBCompiler",
            targets: ["EASBCompiler"]),
        .executable(
            name: "EASBDriver",
            targets: ["EASBDriver"]),
    ],
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EASBCompiler",
            dependencies: [],
            exclude: ["Resources/ExampleCode-outdated.rtf", "Resources/CodeExample.txt", "Resources/SyntaxHighlightingExample.pdf"],
            resources: [.process("Resources/Keywords.txt"), .process("Resources/Instructions.txt"), .process("Resources/Colors.xcassets")]),
        .executableTarget(
            name: "EASBDriver",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"), .target(name: "EASBCompiler")]),
        .testTarget(
            name: "EASBTests",
            dependencies: ["EASBCompiler"]),
    ]
)
