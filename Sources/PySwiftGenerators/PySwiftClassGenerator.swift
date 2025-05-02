//
//  PySwiftClassGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapper

struct PySwiftClassGenerator: MemberMacro {
    
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        
        guard
            node.attributeName.description == "PyClass",
            let cls_decl = declaration.as(ClassDeclSyntax.self)
        else { return []}
        
        let members = Array(declaration.memberBlock.members)
        
        let cls_name = cls_decl.name.text
        
        let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
            let decl = member.decl
            return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
                fdecl
            } else { nil }
        }
        
        
        
        return [
            PyMethods(cls: cls_name, input: py_functions).output,
            "\nstatic let pyTypeObject = \(raw: PyTypeObjectStruct(name: cls_name).output)"
        ]
    }
}


extension PySwiftClassGenerator: ExtensionMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        if let cls = declaration.as(ClassDeclSyntax.self) {
            return [
                try PyClass(name: cls.name.text, cls: cls).extensions()
            ]
        }
        
        return []
    }
}
