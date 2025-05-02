//
//  PySwiftGenerators.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct PyMethodAttribute: PeerMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

struct PyPropertyAttribute: PeerMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

@main
struct PySwiftGeneratorsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PySwiftFuncWrapper.self,
        PyPropertyAttribute.self,
        PyMethodAttribute.self,
        PySwiftClassGenerator.self,
        PySwiftModuleGenerator.self
    ]
}
