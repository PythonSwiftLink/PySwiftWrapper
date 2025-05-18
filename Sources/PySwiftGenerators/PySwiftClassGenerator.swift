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
                    case "unretained":
                        unretained = .init(arg.expression.description) ?? false
                    case "bases":
                        switch arg.expression.kind {
                        case .arrayExpr:
                            guard let array = arg.expression.as(ArrayExprSyntax.self) else { fatalError() }
                            //fatalError("argumentList")
                            bases = array.elements.compactMap { element in
                                if let enum_case = element.expression.as(MemberAccessExprSyntax.self) {
                                    //fatalError("argumentList")
                                    return PyClassBase(rawValue: enum_case.declName.baseName.text)
                                } else { return nil }
                            }
                        case .memberAccessExpr:
                            guard let member = arg.expression.as(MemberAccessExprSyntax.self) else { fatalError() }
                            if member.declName.baseName.text == "all" {
                                bases = .all
                            }
                        default: break
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
        
        
//        guard
//            node.attributeName.description == "PyClass"
//        else { return []}
        
        let info = PyClassArguments(node: node)
        let members = Array(declaration.memberBlock.members)
        //
        switch declaration.kind {
        case .classDecl:
            let cls_decl = declaration.as(ClassDeclSyntax.self)!
            
                        
            let cls_name = cls_decl.name.text
            
            let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
                let decl = member.decl
                return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
                    fdecl
                } else { nil }
            }
            
            let py_properties = members.compactMap { member -> VariableDeclSyntax? in
                let decl = member.decl
                return if decl.is(VariableDeclSyntax.self), let vdecl = decl.as(VariableDeclSyntax.self), vdecl.isPyProperty {
                    vdecl
                } else { nil }
            }
            
            let hasMethods = py_functions.count > 0
            let hasGetSets = py_properties.count > 0
            
            let type_struct = PyTypeObjectStruct(
                name: cls_name,
                bases: info.bases,
                unretained: info.unretained,
                hasMethods: hasMethods,
                hasGetSets: hasGetSets
            )
//            let py_cls = PyClass(
//                name: cls_name,
//                cls: cls_decl,
//                bases: info.bases,
//                unretained: info.unretained
//            )
            var decls: [DeclSyntax] = [
                "\nstatic var pyTypeObject = \(raw: type_struct.output)",
                .init(type_struct.createPyType())
            ]
            if hasGetSets {
                let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties)
                decls.append(getsets.output)
            }
            if hasMethods {
                decls.append(PyMethods(cls: cls_decl.name.text, input: py_functions).output)
            }
            return decls
            
        case .extensionDecl:
            guard let extDecl = declaration.as(ExtensionDeclSyntax.self) else { fatalError("not ext")}
            let cls_name = extDecl.extendedType.trimmedDescription
            
            
//            let py_functions = members.compactMap { member -> FunctionDeclSyntax? in
//                let decl = member.decl
//                return if decl.is(FunctionDeclSyntax.self), let fdecl = decl.as(FunctionDeclSyntax.self), fdecl.isPyMethod {
//                    fdecl
//                } else { nil }
//            }
//
            
            var py_properties = [VariableDeclSyntax]()
            var methods = [FunctionDeclSyntax]()
            
            for member in members {
                let decl = member.decl
                switch decl.kind {
                case .variableDecl:
                    if let v = decl.as(VariableDeclSyntax.self), v.isPyProperty {
                        py_properties.append(v)
                    }
                case .functionDecl:
                    if let f = decl.as(FunctionDeclSyntax.self), f.isPyMethod {
                        methods.append(f)
                    }
                case .macroExpansionDecl:
                    if let exp = member.decl.as(MacroExpansionDeclSyntax.self), exp.macroName.text == "PyWrapCode" {
//                        let pywrapcode = try PyWrapCodeArguments(arguments: exp.arguments)
//                        py_properties.append(contentsOf: pywrapcode.properties)
//                        methods.append(contentsOf: pywrapcode.functions)
                    }
                default: continue
                }
            }
            var bases: [PyClassBase] = []
            if let arguments = node.arguments {
                switch arguments {
                case .argumentList(let listexpr):
                    let py_ext = try PyClassByExtensionUnpack(arguments: listexpr)
                    bases = py_ext.bases
                    methods.append(contentsOf: py_ext.functions)
                    py_properties.append(contentsOf: py_ext.properties)
                default: break
                }
                
            }
//            let py_properties = try members.compactMap { member -> [VariableDeclSyntax]? in
//                let decl = member.decl
//                return switch decl.kind {
//                case .variableDecl:
//                    if let v = decl.as(VariableDeclSyntax.self), v.isPyProperty {
//                        [v]
//                    } else { nil }
//                case .macroExpansionDecl:
//                    if let exp = member.decl.as(MacroExpansionDeclSyntax.self), exp.macroName.text == "PyWrapCodd" {
//                        try PyMethodArguments(arguments: exp.arguments).properties
//                    } else { nil }
//                default: nil
//                }
//            }.flatMap(\.self)
            
            
//            let macro_exps = (members.lazy.compactMap { member in
//                switch member.decl.kind {
//                case .macroExpansionDecl: member.decl.as(MacroExpansionDeclSyntax.self)
//                default: nil
//                }
//            })
//            var methods = try macro_exps.compactMap { member in
//                try PyMethodArguments(arguments: member.arguments).function
//            }
            
//            let methods = try members.lazy.compactMap { member in
//                let decl = member.decl
//                return switch decl.kind {
//                case .macroExpansionDecl:
//                    if let exp = member.decl.as(MacroExpansionDeclSyntax.self), exp.macroName.text == "PyMethodEx" {
//                        try PyMethodArguments(arguments: exp.arguments).functions
//                    } else { nil }
//                case .functionDecl:
//                    if let f = decl.as(FunctionDeclSyntax.self), f.isPyMethod {
//                        [f]
//                    } else { nil }
//                default: nil
//                }
//            }.flatMap(\.self)
            
            let hasMethods = methods.count > 0
            let hasGetSets = py_properties.count > 0
            
            let type_struct = PyTypeObjectStruct(
                name: cls_name,
                bases: bases,
                unretained: info.unretained,
                hasMethods: hasMethods,
                hasGetSets: hasGetSets
            )
            
            
            
            let py_cls = PyClass(
                name: cls_name,
                ext: extDecl,
                bases: bases,
                unretained: info.unretained
            )
            let py_methods = PyMethods(cls: cls_name, input: methods)
            
            var decls = try py_cls.decls()
            
            if hasMethods {
                decls.append(py_methods.output)
            }
            
            if hasGetSets {
                let getsets = PyGetSetDefs(cls: cls_name.typeSyntax, properties: py_properties)
                decls.append(getsets.output)
            }
            
            return decls + [
                "\nstatic var pyTypeObject = \(raw: type_struct.output)",
                .init(type_struct.createPyType()),
                py_cls.asPyPointer(),
                py_cls.asUnretainedPyPointer()
            ]
        default:
            return []
        }
        
    }
}

extension PySwiftClassGenerator: MemberAttributeMacro {
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingAttributesFor member: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AttributeSyntax] {
        
        
        return [
           // .init("Hello".typeSyntax)
        ]
    }
}


extension PySwiftClassGenerator: ExtensionMacro {
    
    
    static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        
        let pyclass_args = PyClassArguments(node: node)
        
        
        
        
        if let cls = declaration.as(ClassDeclSyntax.self) {
            let py_cls = PyClass(
                name: cls.name.text,
                cls: cls,
                bases: pyclass_args.bases,
                unretained: pyclass_args.unretained
            )
            
            return [
                try py_cls.extensions(),
                .init(
                    extendedType: TypeSyntax(stringLiteral: cls.name.text),
                    inheritanceClause: .init {
                        [InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "PyClassProtocol"))]
                    },
                    memberBlock: .init(members: [])
                )
            ]
        }
        
        return []
    }
}

struct AttachedTestMacro: CodeItemMacro, DeclarationMacro {
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        ["print()"]
    }
    
    
    
    
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.CodeBlockItemSyntax] {
        guard let closure = node.trailingClosure else { fatalError() }
        return [
            """
            let _ = if PyGILState_Check() == 0 {
                if let state = PyThreadState_Get() {
                    \(raw: closure.statements)
                } else {
                    let gil = PyGILState_Ensure()
                    \(raw: closure.statements)
                    PyGILState_Release(gil)
                }
            } else {
                \(raw: closure.statements)
                PyEval_SaveThread()
            }
            """
        ]
    }
    
    
    static func _expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard let closure = node.trailingClosure else { fatalError() }
        return """
        let _ = if PyGILState_Check() == 0 {
            if let state = PyThreadState_Get() {
                \(raw: closure.statements)
            } else {
                let gil = PyGILState_Ensure()
                \(raw: closure.statements)
                PyGILState_Release(gil)
            }
        } else {
            \(raw: closure.statements)
            PyEval_SaveThread()
        }
        """
    }
    
    static func _expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        return []
    }
    
    
}

