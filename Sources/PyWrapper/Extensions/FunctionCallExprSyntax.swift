//
//  FunctionCallExprSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
//

import SwiftSyntax

extension FunctionCallExprSyntax {
    static func pyErr_SetString(_ string: String) -> Self {
        
        return .init(callee: ExprSyntax(stringLiteral: "PyErr_SetString") ) {
            LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "PyExc_IndexError"))
            //LabeledExprSyntax(expression: StringLiteralExprSyntax(content: "\(string)"))
            LabeledExprSyntax(expression: string.makeLiteralSyntax() )
        }
    }
    
    static func pyDict_GetItem(_ o: String, _ key: String) -> Self {
        
        return .init(callee: ExprSyntax(stringLiteral: "PyDict_GetItem") ) {
            LabeledExprSyntax(expression: ExprSyntax(stringLiteral: o))
            //LabeledExprSyntax(expression: StringLiteralExprSyntax(content: "\(key)"))
            LabeledExprSyntax(expression: key.makeLiteralSyntax() )
        }
    }
    
    static func pyTuple_GetItem(_ o: String, _ key: Int) -> Self {
        
        return .init(callee: ExprSyntax(stringLiteral: "PyTuple_GetItem") ) {
            LabeledExprSyntax(expression: ExprSyntax(stringLiteral: o))
            LabeledExprSyntax(expression: IntegerLiteralExprSyntax(key) )
        }
    }
    
}

func unsafeBitCast(pymethod: ClosureExprSyntax, from type: String, to: String) -> FunctionCallExprSyntax {
    .init(
        calledExpression: DeclReferenceExprSyntax(baseName: .identifier("unsafeBitCast")),
        leftParen: .leftParenToken(),
        arguments: .init {
            LabeledExprSyntax(expression: AsExprSyntax(
                expression: pymethod.with(\.leftBrace, .leftBraceToken(leadingTrivia: .newline)),
                type: TypeSyntax(stringLiteral: type)
            ))
            LabeledExprSyntax(label: "to", expression: ExprSyntax(stringLiteral: to))
        },
        rightParen: .rightParenToken(leadingTrivia: .newline)
    )
}
