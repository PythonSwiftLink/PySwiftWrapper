//
//  PyMethodDef.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder

public struct PyMethodDefGenerator {
    
    let f: FunctionDeclSyntax
    let parameters: [FunctionParameterSyntax]
    let call: FunctionCallExprSyntax
    let ftype: TypeSyntax
    let canThrow: Bool
    let is_static: Bool
    
    init(cls: String, f: FunctionDeclSyntax) {
        self.f = f
        let parameters = f.signature.parameterClause.parameters.map(\.self)
        let nargs = parameters.count
        let multi = nargs > 1
        
        self.ftype = switch nargs {
        case 0: "PySwiftFunction".typeSyntax()
        case 1: "PySwiftFunction".typeSyntax()
        default: "PySwiftFunctionFast".typeSyntax()
        }
        
        self.parameters = parameters
        
        canThrow = f.signature.effectSpecifiers?.throwsSpecifier != nil || parameters.canThrow
        is_static = f.modifiers.contains { mod in
            mod.name.text == "static"
        }
        
        let call_member = MemberAccessExprSyntax(
            base: is_static ? cls.expr : "UnPackPySwiftObject(with: __self__, as: \(cls).self)".expr,
            name: f.name
        )
        
        self.call = .init(
            calledExpression: call_member,
            leftParen: .leftParenToken(),
            arguments: .init {
                for (i, parameter) in f.signature.parameterClause.parameters.lazy.enumerated() {
                    if let s_name = parameter.secondName, s_name.text == "_" {
                        LabeledExprSyntax(leadingTrivia: .newline, expression: ExprSyntax(stringLiteral: handleTypes(parameter.type, nil)))
                    } else {
                        LabeledExprSyntax(leadingTrivia: .newline,label: parameter.firstName, colon: .colonToken(), expression: ExprSyntax(stringLiteral: handleTypes(parameter.type, multi ? i : nil)))
                    }
                }
            },
            rightParen: nargs > 0 ? .rightParenToken(leadingTrivia: .newline) : .rightParenToken()
        )
        
    }
    
}

extension PyMethodDefGenerator {
    
    fileprivate func arguments(canThrow: Bool = true) -> LabeledExprListSyntax {
        let count = parameters.count
        let label: TokenSyntax = switch count {
        case 0: "noArgs"
        case 1: "oneArg"
        default: "withArgs"
        }
        
        let closure = PyClossure(
            par_count: count,
            callExpr: call,
            argsThrows: parameters.canThrow,
            funcThrows: f.throws
        ).output
    return .init {
        LabeledExprSyntax(leadingTrivia: .newline ,label: label, colon: .colonToken(), expression: f.name.text.makeLiteralSyntax())
        if is_static {
            LabeledExprSyntax(leadingTrivia: .newline ,label: "class_static", colon: .colonToken(), expression: false.makeLiteralSyntax())
        }
        LabeledExprSyntax(leadingTrivia: .newline, label: "ml_meth", colon: .colonToken(), expression: closure)
    }}
    
    public var method: FunctionCallExprSyntax {
        
        return FunctionCallExprSyntax(
            calledExpression: "PyMethodDef".expr,
            leftParen: .leftParenToken(),
            arguments: arguments(canThrow: canThrow),
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
    }
}


extension FunctionCallExprSyntax {

}
