//
//  PySwiftModuleGenerator.swift
//  PySwiftKitMacros
//
//  Created by CodeBuilder on 29/04/2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import PyWrapper

extension AttributeListSyntax.Element {
    var isPyFunction: Bool {
        trimmedDescription.contains("@PyFunction")
        
    }
    var isPyMethod: Bool {
        trimmedDescription.contains("@PyMethod")
    }
}

extension AttributeListSyntax {
    var isPyFunction: Bool {
        contains(where: \.isPyFunction)
    }
    var isPyMethod: Bool {
        contains(where: \.isPyMethod)
    }
}

extension FunctionDeclSyntax {
    var isPyFunction: Bool {
        attributes.isPyFunction
    }
    var isPyMethod: Bool {
        attributes.isPyMethod
    }
}

struct PySwiftModuleGenerator: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let members = declaration.memberBlock.members
        
        let module_functions = members.compactMap { member in
            let decl = member.decl
            switch decl.kind {
            case .functionDecl:
                if let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyFunction {
                    return fdecl
                }
                return nil
            default:
                return nil
            }
        }
        
        
        
        return [
            
        ]
    }
}




