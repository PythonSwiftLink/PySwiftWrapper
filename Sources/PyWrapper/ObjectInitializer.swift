import Foundation
import SwiftSyntaxBuilder
import SwiftSyntax


public class ObjectInitializer {
    
    let cls: String
    let decl: InitializerDeclSyntax?
    let pyInit: Bool
    
    public init(cls: String, decl: InitializerDeclSyntax?) {
        self.cls = cls
        self.decl = decl
        self.pyInit = decl != nil
        parameters = decl?.signature.parameterClause.parameters.map(\.self) ?? []
    }
    
    var parameters: [FunctionParameterSyntax]
    
    var canThrow: Bool {
        
        if let _ =  decl?.signature.effectSpecifiers?.throwsSpecifier {
            return true
        }
        
        return parameters.canThrow
    }
    
    func process() {
        for parameter in parameters {
            parameter.type
        }
    }
}

extension ObjectInitializer {
    
    public var output: CodeBlockItemListSyntax { .init {
        if pyInit {
            let parameters_count = parameters.count
            if parameters_count > 0 {
                DoStmtSyntax(catchClauses: .standardPyCatchClauses) {
                    for initvar in initVars { initvar }
                    "let nkwargs = (kw == nil) ? 0 : PyDict_Size(kw)"
                    if_nkwargs(elseCode: .init {
                        "let nargs = PyTuple_Size(_args_)"
                        GuardStmtSyntax.nargs_kwargs(parameters_count)
                        handle_args_n_kwargs
                        
                    })
                    setPointer()
                    "return 0"
                }
            } else {
                setPointer()
                "return 0"
            }
        } else {
            """
            PyErr_SetString(PyExc_NotImplementedError,"\(raw: cls) can only be inited from swift")
            """
            "return -1"
        }
        
    }}
    
}





fileprivate extension ObjectInitializer {
    
    var initVars: [VariableDeclSyntax] {
        parameters.map { arg in
            VariableDeclSyntax(.var, name: .init(stringLiteral: arg.firstName.text ), type: .init(type: arg.type))
            }
    }
    
    func if_nkwargs(elseCode: CodeBlockItemListSyntax) -> IfExprSyntax {
        let if_con = ConditionElementListSyntax {
            ExprSyntax(stringLiteral: "nkwargs >= \(parameters.count)")
        }
        return .init(
            conditions: if_con,
            body: .init(statements: handleKWArgs() ),
            elseKeyword: .keyword(.else),
            elseBody: .codeBlock(.init(statements: elseCode))
        )
    }
    
    func handleKWArgs() -> CodeBlockItemListSyntax {
        
        return .init {
            for arg in parameters {
                let arg_name = arg.firstName.text
                SequenceExprSyntax(elements: .init(itemsBuilder: {
                    //IdentifierExpr(stringLiteral: arg.name)
                    //ExprSyntax(stringLiteral: "\( arg_name)")
                    arg_name.expr
                    AssignmentExprSyntax()
                    TryExprSyntax.pyDict_GetItem("kw", "\(arg_name)")
                }))
            }
        }
    }
    
    var handle_args_n_kwargs: CodeBlockItemListSyntax {
        
        return .init {
            for arg in parameters {
                let con_list = ConditionElementListSyntax {
                    .init {
                        SequenceExprSyntax(elements: .init {
                            //IdentifierExpr(stringLiteral: "__nargs__")
                            "nargs".expr
                            BinaryOperatorExprSyntax(operator: .rightAngleToken(leadingTrivia: .space))
                            0.makeLiteralSyntax()
                        })
                    }
                }
                IfExprSyntax(
                    conditions: con_list,
                    body: .init {
                        //SequenceExprSyntax(pyTuple: arg)
                    },
                    elseKeyword: .keyword(.else),
                    elseBody: .codeBlock(.init {
                        //SequenceExprSyntax(pyDict: arg)
                    })
                )
                //                IfStmt(leadingTrivia: .newline, conditions: con_list) {
                //                    SequenceExprSyntax(pyTuple: arg)
                //                } elseBody: {
                //                    SequenceExprSyntax(pyDict: arg)
                //
                //                }
                
            }
        }
        
        
    }
    
    func setPointer() -> SequenceExprSyntax {
        //let _throws_ = __init__?.throws ?? false
        let _throws_ = false
        let cls_unretained = false
        //let unmanaged = IdentifierExpr(stringLiteral: "Unmanaged")
        let unmanaged = ExprSyntax(stringLiteral: "Unmanaged")
//        let _passRetained = MemberAccessExprSyntax(base: unmanaged, dot: .periodToken(), name: .identifier(cls_unretained ? "passUnretained" : "passRetained"))
        let _passRetained = MemberAccessExprSyntax(base: unmanaged, period: .periodToken(), name: .identifier(cls_unretained ? "passUnretained" : "passRetained"))
        var initExpr: ExprSyntaxProtocol {
            if _throws_ {
                return initPySwiftTargetThrows().with(\.leadingTrivia, .newline)
            } else {
                return initPySwiftTarget().with(\.leadingTrivia, .newline)
            }
        }
        
        let pass = FunctionCallExprSyntax(
            calledExpression: _passRetained,
            leftParen: .leftParenToken(),
            arguments: [.init(expression: initExpr)],
            rightParen: .rightParenToken(leadingTrivia: .newline)
        )
        
        let toOpaque = FunctionCallExprSyntax(callee: MemberAccessExprSyntax(
            base: pass,
            period: .periodToken(),
            name: .identifier("toOpaque")
        ))
        
        
        return .init {
            //Expr(stringLiteral: "PySwiftObject_Cast(__self__).pointee.swift_ptr")
            //            ExprSyntax(stringLiteral: "PySwiftObject_Cast(__self__).pointee.swift_ptr")
            "__self__?.pointee.swift_ptr".expr
            AssignmentExprSyntax()
            toOpaque
        }
    }
    
    func initPySwiftTarget() -> FunctionCallExprSyntax {
        let id = DeclReferenceExprSyntax(baseName: .identifier(cls))
        
        let tuple = LabeledExprListSyntax {
            //LabeledExprSyntax(label: "with", expression: .init(IdentifierExprSyntax(stringLiteral: src)))
            //let many = args.count > 1
//            for arg in args {
//                let arg_name = arg.optional_name ?? arg.name
//                let label = arg.no_label ? nil : arg_name
//                
//                LabeledExprSyntax(label: label, expression: ExprSyntax(stringLiteral: arg_name))
////                if let _arg = arg as? ArgSyntax {
////                    _arg.callTupleElement(many: many)
////                }
//            }
            
        }
        let f_exp = FunctionCallExprSyntax(
            calledExpression: id,
            leftParen: .leftParenToken(),
            arguments: tuple,
            rightParen: .rightParenToken()
        )
        return f_exp
        
        //return TryExprSyntax(tryKeyword: .tryKeyword(trailingTrivia: .space), expression: f_exp)
    }
    
    func initPySwiftTargetThrows() -> TryExprSyntax {
        return .init(expression: initPySwiftTarget())
    }
}
