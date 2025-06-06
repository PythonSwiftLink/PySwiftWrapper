// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "PySwiftWrapper",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PySwiftWrapper",
            targets: ["PySwiftWrapper"]
        ),
        .executable(
            name: "PySwiftKitMacrosClient",
            targets: ["PySwiftKitMacrosClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .target(name: "PyWrapperInfo"),
        .macro(
            name: "PySwiftGenerators",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "PyWrapper",
                "PyWrapperInfo"
            ]
        ),
        .target(
            name: "PyWrapper",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "PyWrapperInfo"
            ]
        ),
        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "PySwiftWrapper",
            dependencies: [
                "PySwiftGenerators",
                "PyWrapperInfo"
            ]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "PySwiftKitMacrosClient", dependencies: ["PySwiftWrapper"]),

    ]
)
