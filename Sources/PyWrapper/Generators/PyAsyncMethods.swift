//
//  PyAsyncMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//



import Foundation
import SwiftSyntax


fileprivate extension String {
    func asLabeledExpr(_ expression: ExprSyntaxProtocol) -> LabeledExprSyntax {
        .init(label: self, expression: expression)
    }
    func asExpr() -> ExprSyntax { .init(stringLiteral: self)}
}



struct PyAsyncMethodsGenerator {
    
    let cls: String
    
    
    var variDecl: VariableDeclSyntax {
        let call = FunctionCallExprSyntax(callee: ".init".expr) {
            _am_await(cls: cls).labeledExpr().with(\.leadingTrivia, .newline).newLineTab
            _am_aiter(cls: cls).labeledExpr().newLineTab
            _am_anext(cls: cls).labeledExpr().newLineTab
            _am_send(cls: cls).labeledExpr()
        }.with(\.rightParen, .rightParenToken(leadingTrivia: .newline))
        
        return .init(
            leadingTrivia: .lineComment("// #### PyAsyncMethods ####").appending(.newlines(2) as Trivia),
            modifiers: [.fileprivate, .static], .var,
            name: .init(stringLiteral: "tp_as_async"),
            type: .init(type: TypeSyntax(stringLiteral: "PyAsyncMethods")),
            initializer: .init(value: call)
        ).with(\.trailingTrivia, .newlines(2))
        
    }
    
    var methods: [any PyAsyncMethodProtocol] {
        return [
            _am_await(cls: cls),
            _am_aiter(cls: cls),
            _am_anext(cls: cls),
            _am_send(cls: cls)
        ]
    }
    
    init(cls: String) {
        self.cls = cls
    }
    
}

protocol PyAsyncMethodProtocol {
    var label: String { get }
    var cls: String { get }
    var type: PyType_typedefs { get }
    func closureExpr() -> ClosureExprSyntax
    func _protocol() -> FunctionDeclSyntax
}

extension PyAsyncMethodProtocol {
    func labeledExpr() -> LabeledExprSyntax {
        label.asLabeledExpr(unsafeBitCast(pymethod: closureExpr(), from: "\(swift_type)", to: "\(type).self"))
    }
    var swift_type: String { "PySwift_\(type)" }
}
fileprivate func unPackSelf(_ cls: String, arg: String = "__self__") -> ExprSyntax {
    .UnPackPySwiftObject(cls, arg: arg)
}
extension PyAsyncMethodsGenerator {
    
    
    
    struct _am_await: PyAsyncMethodProtocol {
        let label = "am_await"
        let cls: String
        let type: PyType_typedefs = .unaryfunc
        
        
        func closureExpr() -> ClosureExprSyntax {
            .unaryfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__am_await__()
                } else { nil }
                """
            }
        }
        
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __am_await__() -> PyPointer?
            """)
        }
    }
    
    struct _am_aiter: PyAsyncMethodProtocol {
        let label = "am_aiter"
        let cls: String
        let type: PyType_typedefs = .unaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .unaryfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__am_aiter__()
                } else { nil }
                """
            }
        }
        
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __am_aiter__() -> PyPointer?
            """)
        }
    }
    
    struct _am_anext: PyAsyncMethodProtocol {
        let label = "am_anext"
        let cls: String
        let type: PyType_typedefs = .unaryfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .unaryfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__am_anext__()
                } else { nil }
                """
            }
        }
        
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __am_anext__() -> PyPointer?
            """)
        }
    }
    
    struct _am_send: PyAsyncMethodProtocol {
        let label = "am_send"
        let cls: String
        let type: PyType_typedefs = .sendfunc
        
        func closureExpr() -> ClosureExprSyntax {
            .sendfunc {
                """
                if let __self__ {
                    \(raw: unPackSelf(cls)).__am_send__(__args__, kw).result()
                } else { PYGEN_ERROR }
                """
            }
        }
        func _protocol() -> FunctionDeclSyntax {
            try! .init("""
            func __am_send__(_ arg: PyPointer?,_ kwargs: UnsafeMutablePointer<PyPointer?>?) -> PySendResultFlag
            """)
        }
    }
    
    
}

