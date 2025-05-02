//
//  PyClass.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import SwiftSyntax
import PyWrapperInfo

public class PyClass {
    let name: String
    var initDecl: InitializerDeclSyntax?
    var bases: [PyClassBase]
    var unretained: Bool
    
    public init(name: String, cls: ClassDeclSyntax, bases: [PyClassBase] = [], unretained: Bool = false) {
        self.name = name
        self.bases = bases
        self.unretained = unretained
        let inits = cls.memberBlock.members.compactMap { member in
            let decl = member.decl
            if decl.kind == .initializerDecl {
                return decl.as(InitializerDeclSyntax.self)
            }
            return nil
        }
        initDecl = inits.first
    }
    
}

extension PyClass {
    
    var extensionType: TypeSyntax { .init(stringLiteral: name) }
    
    public func extensions() throws -> ExtensionDeclSyntax {
        .init(modifiers: [.init(name: .keyword(.fileprivate))], extendedType: extensionType) {
            tp_new()
            tp_init()
            tp_dealloc()
            
            for base in self.bases {
                switch base {
                case .async:
                    PyAsyncMethodsGenerator(cls: name).variDecl
                case .sequence:
                    ""
                case .mapping:
                    PyMappingMethodsGenerator(cls: name).variDecl
                case .buffer:
                    ""
                case .number:
                    ""
                }
            }
            
        }
    }
}


fileprivate extension PyClass {
    var create_tp_init: ClosureExprSyntax {
        
        let closure = if initDecl != nil {
            ExprSyntax(stringLiteral: "{ __self__, _args_, kw -> Int32 in }").as(ClosureExprSyntax.self)!
        } else {
            ExprSyntax(stringLiteral: "{ _, _, _ -> Int32 in }").as(ClosureExprSyntax.self)!
        }
        return closure.with(\.statements, .init {
            ObjectInitializer(cls: name, decl: initDecl).output
        })
        
    }
    
    func tp_init() -> VariableDeclSyntax {
        
        return .init(
            modifiers: [ .init(name: .keyword(.static))], .var,
            name: .init(stringLiteral: "tp_init"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_initproc")),
            initializer: .init(value: create_tp_init)
        ).with(\.trailingTrivia, .newlines(2))
    }
    
    func tp_new() -> VariableDeclSyntax {
        return .init(
            modifiers: [ .init(name: .keyword(.static))], .var,
//            modifiers: [.init(name: .keyword(.fileprivate)), .init(name: .keyword(.static))], .var,
            name: .init(stringLiteral: "tp_new"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_newfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { type, _, _ -> PyPointer? in
                PySwiftObject_New(type)
                }
                """))
        ).with(\.leadingTrivia, .newlines(2)).with(\.trailingTrivia, .newlines(2))
    }
    
    func tp_dealloc(target: String? = nil) -> VariableDeclSyntax {
        
        return .init(
            modifiers: [ .init(name: .keyword(.static))], .var,
            name: .init(stringLiteral: "tp_dealloc"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_destructor")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
            { s in
            if let ptr = s?.pointee.swift_ptr {
            Unmanaged<\(target ?? name)>.fromOpaque(ptr).release()
            }
            }
            """)).with(\.trailingTrivia, .newlines(2))
        )
    }
}
