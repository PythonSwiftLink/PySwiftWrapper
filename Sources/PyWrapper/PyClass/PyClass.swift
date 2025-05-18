//
//  PyClass.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import SwiftSyntax
import SwiftSyntaxBuilder
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
    
    public init(name: String, ext: ExtensionDeclSyntax, bases: [PyClassBase] = [], unretained: Bool = false) {
        self.name = name
        self.bases = bases
        self.unretained = unretained
        let inits = ext.memberBlock.members.compactMap { member in
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
    
    public func decls() throws -> [DeclSyntax] {
        
        var out: [DeclSyntax] = [
            tp_new().declSyntax,
            tp_init().declSyntax,
            tp_dealloc().declSyntax
        ]
        let name = name
        let base_methods = bases.lazy.compactMap {[unowned self] base -> VariableDeclSyntax? in
            switch base {
            case .async:
                PyAsyncMethodsGenerator(cls: name).variDecl
            case .sequence:
                PySequenceMethodsGenerator(cls: name).variDecl
            case .mapping:
                PyMappingMethodsGenerator(cls: name).variDecl
            case .buffer:
                nil
            case .number:
                PyNumberMethodsGenerator(cls: name).variDecl
            case .hash:
                tp_hash(target: name)
            case .str:
                tp_str(target: name)
            default:
                nil
            }
        }
        out.append(contentsOf: base_methods.map(\.declSyntax))
        
        return out
    }
    
    public func extensions() throws -> ExtensionDeclSyntax {
        .init(modifiers: [], extendedType: extensionType) {
            tp_new()
            tp_init()
            tp_dealloc()
            
            
            
            for base in self.bases {
                switch base {
                case .async:
                    PyAsyncMethodsGenerator(cls: name).variDecl
                case .sequence:
                    PySequenceMethodsGenerator(cls: name).variDecl
                case .mapping:
                    PyMappingMethodsGenerator(cls: name).variDecl
                case .buffer:
                    ""
                case .number:
                    PyNumberMethodsGenerator(cls: name).variDecl
                case .hash:
                    tp_hash(target: name)
                case .str:
                    tp_str(target: name)
                default:
                    ""
                }
            }
            
            self.asPyPointer()
            self.asUnretainedPyPointer()
        }
    }
    
    
}


public extension PyClass {
    
    var create_tp_init_new: ClosureExprSyntax {
        .initproc {
            
        }
    }
    
    var create_tp_init: ClosureExprSyntax {
 
        let closure = if let initDecl {
            ExprSyntax(stringLiteral: "{ __self__, \(initDecl.signature.parameterClause.parameters.count > 1 ? "_args_" : "__arg__"), kw -> Int32 in }").as(ClosureExprSyntax.self)!
        } else {
            ExprSyntax(stringLiteral: "{ _, _, _ -> Int32 in }").as(ClosureExprSyntax.self)!
        }
        return closure.with(\.statements, .init {
            ObjectInitializer(cls: name, decl: initDecl).outputNew
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
    
    func asPyPointer() -> DeclSyntax {
        
        return """
        public static func asPyPointer(_ target: \(raw: name)) -> PyPointer {
            let new = PySwiftObject_New(\(raw: name).PyType)
            PySwiftObject_Cast(new).pointee.swift_ptr = Unmanaged.passRetained(target).toOpaque()
            return new!
        }
        """
    }
    
    func asUnretainedPyPointer() -> DeclSyntax {
        
        return """
        public static func asPyPointer(unretained target: \(raw: name)) -> PyPointer {
            let new = PySwiftObject_New(\(raw: name).PyType)
            PySwiftObject_Cast(new).pointee.swift_ptr = Unmanaged.passUnretained(target).toOpaque()
            return new!
        }
        """
    }
    
    func tp_hash(target: String) -> VariableDeclSyntax {
        let expr = ExprSyntax(stringLiteral: """
            { __self__ -> Int in
                UnPackPySwiftObject(with: __self__, as: \(target).self).__hash__()
            }
            """).as(ClosureExprSyntax.self)!
        
        return .init(
            modifiers: [ .init(name: .keyword(.static))], .var,
            name: .init(stringLiteral: "tp_hash"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_hashfunc")),
            initializer: .init(value: expr).with(\.trailingTrivia, .newlines(2))
        )
    }
    
    func tp_str(target: String? = nil) -> VariableDeclSyntax {
        return .init(
            modifiers: [ .init(name: .keyword(.static))], .var,
            name: .init(stringLiteral: "tp_str"),
            type: .init(type: TypeSyntax(stringLiteral: "PySwift_reprfunc")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
                { __self__ in
                    return UnPackPySwiftObject(with: __self__, as: \(target ?? name).self).__str__().pyPointer
                }
                """)
            )//.with(\.trailingTrivia, .newlines(2))
        )
    }
}
