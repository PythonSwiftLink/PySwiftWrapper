//
//  PyTypeObjectStruct.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
//

import Foundation
import SwiftSyntax
import PyWrapperInfo

public struct PyTypeObjectStruct {
    
    let name: String
    let bases: [PyClassBase]
    let unretained: Bool
    let hasMethods: Bool
    let hasGetSets: Bool
    
    
    public init(name: String, bases: [PyClassBase], unretained: Bool = false, hasMethods: Bool, hasGetSets: Bool) {
        self.name = name
        self.bases = bases
        self.unretained = unretained
        self.hasMethods = hasMethods
        self.hasGetSets = hasGetSets
    }
    
}

extension PyTypeObjectLabels {
    func asLabel(_ expr: ExprSyntaxProtocol) -> LabeledExprSyntax {
        .init(label: rawValue, expression: expr)
    }
    func asLabel(_ expr: String) -> LabeledExprSyntax {
        .init(label: rawValue, expression: expr.expr)
    }
}

extension PyTypeObjectStruct {
    
    
    
    fileprivate func setLabel(_ label: PyTypeObjectLabels) -> LabeledExprSyntax {
        
        
        let out: ExprSyntaxProtocol? = switch label {
            
        case .ob_base:
            ".init()".expr
        case .tp_name:
            name.cString()
        case .tp_basicsize:
            "MemoryLayout<PySwiftObject>.stride".expr
        case .tp_itemsize:
            0.makeLiteralSyntax()
        case .tp_dealloc:
            if !unretained {
                "unsafeBitCast(\(name).\(label), to: destructor.self)".expr
            } else { nil }
        case .tp_vectorcall_offset:
            0.makeLiteralSyntax()
        case .tp_getattr:
            nil
        case .tp_setattr:
            nil
        case .tp_as_async:
            bases.contains(.async) ? ".init(&\(name).\(label))".expr : nil
        case .tp_repr:
            bases.contains(.repr) ? "unsafeBitCast(\(name).\(label), to: reprfunc.self)".expr : nil
        case .tp_as_number:
            bases.contains(.number) ? ".init(&\(name).\(label))".expr : nil
        case .tp_as_sequence:
            bases.contains(.sequence) ? ".init(&\(name).\(label))".expr : nil
        case .tp_as_mapping:
            bases.contains(.mapping) ? ".init(&\(name).\(label))".expr : nil
        case .tp_hash:
            bases.contains(.hash) ? "unsafeBitCast(\(name).\(label), to: hashfunc.self)".expr : nil
        case .tp_call:
            nil
        case .tp_str:
            bases.contains(.str) ? "unsafeBitCast(\(name).\(label), to: reprfunc.self)".expr : nil
        case .tp_getattro:
            nil
        case .tp_setattro:
            nil
        case .tp_as_buffer:
            bases.contains(.buffer) ? "\(name).buffer_procs()".expr : nil
        case .tp_flags:
            "NewPyObjectTypeFlag.DEFAULT".expr
        case .tp_doc:
            nil
        case .tp_traverse:
            nil
        case .tp_clear:
            nil
        case .tp_richcompare:
            nil
        case .tp_weaklistoffset:
            0.makeLiteralSyntax()
        case .tp_iter:
            nil
        case .tp_iternext:
            nil
        case .tp_methods:
            hasMethods ? ".init(&PyMethodDefs)".expr : nil
        case .tp_members:
            nil
        case .tp_getset:
            hasGetSets ? ".init(&PyGetSetDefs)".expr : nil
        case .tp_base:
            nil
        case .tp_dict:
            nil
        case .tp_descr_get:
            nil
        case .tp_descr_set:
            nil
        case .tp_dictoffset:
            "MemoryLayout<PySwiftObject>.stride - MemoryLayout<PyObject>.stride".expr
        case .tp_init:
            "unsafeBitCast(\(name).tp_init, to: initproc.self)".expr
        case .tp_alloc:
            "PyType_GenericAlloc".expr
        case .tp_new:
            "\(name).tp_new".expr
        case .tp_free:
            nil
        case .tp_is_gc:
            nil
        case .tp_bases:
            nil
        case .tp_mro:
            nil
        case .tp_cache:
            nil
        case .tp_subclasses:
            nil
        case .tp_weaklist:
            nil
        case .tp_del:
            nil
        case .tp_version_tag:
            "UInt32(Py_Version)".expr
        case .tp_finalize:
            nil
        case .tp_vectorcall:
            nil
        }
        
        if label == .tp_vectorcall {
            return .init(label: label.rawValue, expression: NilLiteralExprSyntax())
        }
        return if let out {
            .init(label: label.rawValue, expression: out).newLineTab
        } else {
            .init(label: label.rawValue, expression: NilLiteralExprSyntax()).newLineTab
        }
    }
    
    fileprivate var arguments: LabeledExprListSyntax {
        
        
        
        return .init {
            for label in PyTypeObjectLabels.allCases {
                setLabel(label)
            }
        }
    }
    
}


extension PyTypeObjectStruct {
    public var output: FunctionCallExprSyntax {
        .init(
            calledExpression: ExprSyntax(stringLiteral: "PyTypeObject"),
            leftParen: .leftParenToken(),//(trailingTrivia: .newline), //.appending(.tab)
            arguments: arguments.with(\.leadingTrivia, .newline),
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
    }
    
    public func createPyType() -> VariableDeclSyntax {
        return .init(
            modifiers: [ .public, .static], .let,
            name: .init(stringLiteral: "PyType"),
            type: .init(type: TypeSyntax(stringLiteral: "UnsafeMutablePointer<PyTypeObject>")),
            initializer: .init(value: ExprSyntax(stringLiteral: """
            {
                let t: UnsafeMutablePointer<PyTypeObject> = .init(&pyTypeObject)
                if PyType_Ready(t) < 0 {
                    PyErr_Print()
                    fatalError("PyReady failed")
                }
                return t
            }()
            """)).with(\.trailingTrivia, .newlines(2))
        )
    }
}


