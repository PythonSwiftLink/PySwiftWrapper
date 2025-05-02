//
//  PyClossure.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 29/04/2025.
//

import SwiftSyntax

public class PyClossure {
    
    var par_count: Int
    
    var callExpr: FunctionCallExprSyntax
    
    var argsThrows: Bool
    
    var funcThrows: Bool
    
    public init(par_count: Int, callExpr: FunctionCallExprSyntax, argsThrows: Bool = true, funcThrows: Bool = false) {
        self.par_count = par_count
        self.callExpr = callExpr
        self.argsThrows = argsThrows
        self.funcThrows = funcThrows
    }
    
    
}

extension PyClossure {
    
    var extracts_conditions: ConditionElementListSyntax {
        .init {
            switch par_count {
            case 0:
                ConditionElementSyntax(condition: .expression(" let __self__"), trailingTrivia: .space)
            case 1:
                ConditionElementSyntax(condition: .expression(" let __self__"))
                ConditionElementSyntax(condition: .expression(" let __arg__"), trailingTrivia: .space)
            default:
                ConditionElementSyntax(condition: .expression(" nargs == \(raw: par_count)"))
                ConditionElementSyntax(condition: .expression(" let __self__"))
                ConditionElementSyntax(condition: .expression(" let __args__"), trailingTrivia: .space)
            }
        }
    }
    
    var extracts: GuardStmtSyntax {
       // .init(conditions: extracts_conditions, elseKeyword: .poundElseToken(leadingTrivia: .newline), body: .init {} )
        .init(conditions: extracts_conditions) {
            "return nil"
        }
    }
}

extension PyClossure {
    private var parameters: ClosureParameterListSyntax {.init {
        "__self__"
        switch par_count {
        case 0: 
            "_"
        case 1: "__arg__"
        default: 
            "__args__"
            "nargs"
        }
    }}
    
    private var signature: ClosureSignatureSyntax {
        return .init(parameterClause: .parameterClause(.init(parameters: parameters)))
    }
    
    private var statements: CodeBlockItemListSyntax {
        let body: CodeBlockSyntax = .init {
            extracts
            if funcThrows {
                TryExprSyntax(expression: callExpr)
            } else {
                callExpr
            }
            "return .None"
        }
        return .init {
            
            if argsThrows || funcThrows {
                DoStmtSyntax(
                    body: body,
                    catchClauses: .standardPyCatchClauses
                )
                "return nil"
            } else {
                body.statements
            }
            
        }
    }
    
    public var output: ClosureExprSyntax { .init(signature: signature, statements: statements) }
}
