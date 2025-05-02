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

@main
struct PySwiftGeneratorsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PySwiftFuncWrapper.self,
        PySwiftMethodWrapper.self,
        PySwiftClassGenerator.self,
        PySwiftModuleGenerator.self
    ]
}
