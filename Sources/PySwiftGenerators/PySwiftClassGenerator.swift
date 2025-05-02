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
import PyWrapperInfo


class PyClassArguments {
    var bases: [PyClassBase] = []
    var unretained = false
    
    init(node: AttributeSyntax) {
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let labeledExprList):
                for arg in labeledExprList {
                    guard let label = arg.label else { continue }
                    switch label.text {
                    case "unretwined":
                        unretained = .init(arg.expression.description) ?? false
                    case "bases":
                        guard let array = arg.expression.as(ArrayExprSyntax.self) else { continue }
                        bases = array.elements.compactMap { element in
                            if let enum_case = element.expression.as(EnumCaseElementSyntax.self) {
                                PyClassBase(rawValue: enum_case.name.text)
                            } else { nil }
                        }
                    default: break
                    }
                }
            default: break
            }
        }
    }
}

struct PySwiftClassGenerator: MemberMacro {
    
    
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        
        guard
            node.attributeName.description == "PyClass",
            let cls_decl = declaration.as(ClassDeclSyntax.self)
        else { return []}
        
        let info = PyClassArguments(node: node)
        
        let members = Array(declaration.memberBlock.members)
        
        let cls_name = cls_decl.name.text
        
        let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
            let decl = member.decl
            return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
                fdecl
            } else { nil }
        }
        
        let type_struct = PyTypeObjectStruct(
            name: cls_name,
            bases: info.bases,
            unretained: info.unretained
        )
        
        return [
            PyMethods(cls: cls_name, input: py_functions).output,
            "\nstatic let pyTypeObject = \(raw: type_struct.output)"
        ]
    }
}


extension PySwiftClassGenerator: ExtensionMacro {
    static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        
        let pyclass_args = PyClassArguments(node: node)
        
        
        
        
        if let cls = declaration.as(ClassDeclSyntax.self) {
            return [
                try PyClass(
                    name: cls.name.text,
                    cls: cls,
                    bases: pyclass_args.bases,
                    unretained: pyclass_args.unretained
                ).extensions()
            ]
        }
        
        return []
    }
}
