//
//  PyCallbackGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 04/05/2025.
//
import SwiftSyntax
import SwiftSyntaxMacros
import PyWrapper

extension AttributeListSyntax.Element {
    var isPyCall: Bool { trimmedDescription.contains("@PyCall") }
}

extension AttributeListSyntax {
    var isPyCall: Bool { contains(where: \.isPyCall) }
}

extension FunctionDeclSyntax {
    var isPyCall: Bool { attributes.isPyCall }
}

struct PyCallbackGenerator: MemberMacro {
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        let members = Array(declaration.memberBlock.members)
        
        let py_calls = members.compactMap { member -> FunctionDeclSyntax? in
            let decl = member.decl
            return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyCall {
                fdecl
            } else { nil }
        }
        
        var output: [DeclSyntax] = [
            "let py_target: PyPointer"
        ]
        
        
        
        for py_call in py_calls {
            let call_name = py_call.name
            output.append("""
            let _\(raw: call_name): PyPointer
            """)
        }
        
        let initSignature = FunctionSignatureSyntax(
            parameterClause: .init(parameters: .init {
                .init(firstName: .identifier("object"), type: "PyPointer".typeSyntax)
            }),
            effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws)))
        )
        
        let initDecl = InitializerDeclSyntax(signature: initSignature) {
            "py_target = object"
            for py_call in py_calls {
                """
                _\(raw: py_call.name) = if PyObject_HasAttr(object, "\(raw: py_call.name)") {
                    PyObject_GetAttr(object, "\(raw: py_call.name)")!
                } else { fatalError() }
                """
            }
        }
        
        output.append(.init(initDecl))
        
        return output
    }
}

class PyCallArguments {
    var gil = true
    
    init(node: AttributeSyntax) {
        if let arguments = node.arguments {
            switch arguments {
            case .argumentList(let labeledExprList):
                for arg in labeledExprList {
                    guard let label = arg.label else { continue }
                    switch label.text {
                    case "gil":
                        gil = .init(arg.expression.description) ?? true
         
                        
                    default: break
                    }
                }
            default: break
            }
        }
    }
}

struct PyCallFiller: BodyMacro {
    
    static func expansion(of node: AttributeSyntax, providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax, in context: some MacroExpansionContext) throws -> [CodeBlockItemSyntax] {
        guard let fdecl = declaration.as(FunctionDeclSyntax.self) else { return [] }
        let info = PyCallArguments(node: node)
        let pycall = PyCallGenerator.init(function: fdecl, gil: info.gil)
        return pycall.output.map(\.self)
//
//        return ["""
//        do \(raw: pycall.output)
//        catch let err as PyStandardException {
//            err.pyExceptionError()
//        } catch let err as PyException {
//            err.pyExceptionError()
//        } catch let other_error {
//            other_error.anyErrorException()
//        }
//        """]
    }
    
    static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        []
    }
    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        
        var output = [DeclSyntax]()
        output.append("""
        """)
        return output
    }
}
