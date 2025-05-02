//
//  PyMappingMethodsGenerator.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//
import Foundation
import SwiftSyntax

protocol PyMappingMethodProtocol {
    var label: String { get }
    var cls: String { get }
    var type: PyType_typedefs { get }
    func closureExpr() -> ClosureExprSyntax
    func _protocol() -> FunctionDeclSyntax
}

extension PyMappingMethodProtocol {
    func labeledExpr() -> LabeledExprSyntax {
        .init(label: label, expression: unsafeBitCast(pymethod: closureExpr(), from: "PySwift_\(type)", to: "\(type).self"))
    }
}

struct PyMappingMethodsGenerator {
	
    let cls: String
	
	var methods: [any PyMappingMethodProtocol] {
		return [
			_mp_length(cls: cls),
			_mp_subscript(cls: cls),
			_mp_ass_subscript(cls: cls),
		]
	}
	
	var variDecl: VariableDeclSyntax {
        let call = FunctionCallExprSyntax(callee: ".init".expr) {
			_mp_length(cls: cls).labeledExpr().with(\.leadingTrivia, .newline).newLineTab
			_mp_subscript(cls: cls).labeledExpr().newLineTab
			_mp_ass_subscript(cls: cls).labeledExpr()
		}.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
		
		return .init(
			leadingTrivia: .lineComment("// #### PyMappingMethods ####").appending(.newlines(2) as Trivia),
			modifiers: [.static], .var,
			name: .init(stringLiteral: "tp_as_mapping"),
			type: .init(type: TypeSyntax(stringLiteral: "PyMappingMethods")),
			initializer: .init(value: call)
		).with(\.trailingTrivia, .newlines(2))
		
	}
	
    init(cls: String) {
		self.cls = cls
	}
	
}

fileprivate func unPackSelf(_ cls: String, arg: String = "__self__") -> ExprSyntax {
    .UnPackPySwiftObject(cls, arg: arg)
}

extension PyMappingMethodsGenerator {
    
    
    
    struct _mp_length: PyMappingMethodProtocol {
        let label = "mp_length"
        let cls: String
        let type: PyType_typedefs = .lenfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .lenfunc {"""
                if let __self__ {
                    \(raw: unPackSelf(cls)).__len__()
                } else { 0 }
                """
            }
        }
        
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __len__() -> Int
            """)
        }
    }
    
    struct _mp_subscript: PyMappingMethodProtocol {
        let label = "mp_subscript"
        let cls: String
        let type: PyType_typedefs = .binaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .binaryfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__getitem__(o)
                } else { nil }
                """
            }
        }
        
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __getitem__(_ key: PyPointer?) -> PyPointer?
            """)
        }
    }
    
    struct _mp_ass_subscript: PyMappingMethodProtocol {
        let label = "mp_ass_subscript"
        let cls: String
        let type: PyType_typedefs = .objobjargproc
        
        func closureExpr() -> ClosureExprSyntax {
            .objobjargproc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__setitem__(x, y)
                } else { 0 }
                """
            }
        }
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __setitem__(_ key: PyPointer?,_ item: PyPointer?) -> Int32
            """)
        }
    }
    
    
}
