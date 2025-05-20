//
//  PyCallback.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 04/05/2025.
//
import SwiftSyntax

fileprivate extension String {
    var labelExpr: LabeledExprSyntax { .init(expression: self.expr) }
}


public class PyCallGenerator {
    let parameters: [FunctionParameterSyntax]
    let returnType: TypeSyntax?
    let arg_count: Int
    //let function: FunctionDeclSyntax
    let call_name: String
    var canThrow: Bool
    var funcThrows: Bool
    var gil: Bool
    
    public init(function: FunctionDeclSyntax, gil: Bool) {
        //self.function = function
        self.call_name = function.name.trimmedDescription
        self.gil = gil
        let signature = function.signature
        let parameters = Array(signature.parameterClause.parameters)
        self.parameters = parameters
        arg_count = parameters.count
        let rtn = signature.returnClause
        canThrow = function.throws
        funcThrows = function.throws
        if let rtn {
            returnType = rtn.type
            if rtn.canThrow {
                canThrow = true
            }
        } else {
            returnType = nil
        }
    }
    
    
}

extension PyCallGenerator {
    public enum Mode {
        case single
        case multi
    }
    
    var callee: ExprSyntax {
        switch arg_count {
        case 0: "PyObject_CallNoArgs"
        case 1: "PyObject_CallOneArg"
        default: "PyObject_Vectorcall"
        }
    }
    
    var call: FunctionCallExprSyntax {
        return .init(callee: callee) {
            "_\(call_name)".labelExpr
            if arg_count > 0 {
                switch arg_count {
                case 1:
                    "arg".labelExpr
                default:
                    "__args__".labelExpr
                    LabeledExprSyntax(expression: arg_count.makeLiteralSyntax())
                    "nil".labelExpr
                }
            }
        }
    }
}

extension PyCallGenerator {
    var condition: ConditionElementListSyntax {
        .init {
            ConditionElementSyntax(condition: .expression( " let result = \(raw: call)"))
        }
    }
    
    var pre_call: CodeBlockItemListSyntax {
        .init {
            switch arg_count {
            case 0: ""
            case 1:
                let parameter = parameters.first!
                "let arg = \(raw: (parameter.secondName ?? parameter.firstName)).pyPointer"
            default:
                "let __args__ = VectorCallArgs.allocate(capacity: \(raw: arg_count))"
                for (index, parameter) in parameters.enumerated() {
                    let pname = (parameter.secondName ?? parameter.firstName)
                    "__args__[\(raw: index)] = \(raw: pname).pyPointer"
                }
            }
//            if arg_count > 1 {
//                "let __args__ = VectorCallArgs.allocate(capacity: \(raw: arg_count))"
//                for (index, parameter) in parameters.enumerated() {
//                    let pname = (parameter.secondName ?? parameter.firstName)
//                    "__args__[\(raw: index)] = \(raw: pname).pyPointer\n"
//                }
//            }
        }
    }
    
    var post_call: CodeBlockItemListSyntax {
        .init {
            switch arg_count {
            case 0: ""
            case 1: "Py_DecRef(arg)"
            default:
                for index in 0..<arg_count {
                    "Py_DecRef(__args__[\(raw: index)])"
                }
                "__args__.deallocate()"
            }
            
        }
    }
    
    private var code: CodeBlockItemListSyntax {
        let manyArgs = arg_count > 1
        return .init {
            if gil {
                "let gil = PyGILState_Ensure()"
            }
            pre_call
            GuardStmtSyntax(conditions: condition, elseKeyword: .keyword(.else, leadingTrivia: .space)) {
                "PyErr_Print()"
                post_call
                if gil {
                    "PyGILState_Release(gil)"
                }
                if let returnType {
                    if funcThrows {
                        "throw PyStandardException.typeError"
                    } else {
                        "fatalError()"
                    }
                } else {
                    "return"
                }
                
            }
            post_call
            if let returnType {
                if returnType.isPyPointer {
                    if gil {
                        "PyGILState_Release(gil)"
                    }
                    "return result"
                } else {
                    "let _result = try \(raw: returnType)(object: result)"
                    "Py_DecRef(result)"
                    if gil {
                        "PyGILState_Release(gil)"
                    }
                    "return _result"
                }
                
            } else {
                "Py_DecRef(result)"
                if gil {
                    "PyGILState_Release(gil)"
                }
            }
        }
    }
    
    public var output: CodeBlockItemListSyntax {
        .init {
            if canThrow {
                DoStmtSyntax(body: .init(statements: code), catchClauses: .standardPyCatchClauses)
                if returnType != nil {
                    if funcThrows {
                        "throw PyStandardException.typeError"
                    } else {
                        "fatalError()"
                    }
                }
            } else {
                code
            }
        }
    }
    
}


final class PyCallableCodeBlock: PyCallableProtocol {
    
    
    var target: String?
    
    var parameters: [P]
    
    var parameters_count: Int
    
    var returnType: SwiftSyntax.TypeSyntax?
    
    var canThrow: Bool
    
    var gil: Bool
    
    typealias S = FunctionTypeSyntax
    
    typealias P = TupleTypeElementListSyntax.Element
   
    init(syntax: SwiftSyntax.FunctionTypeSyntax, target: String?, gil: Bool) {
        self.target = target
        self.gil = gil
        let parameters = Array(syntax.parameters)
        self.parameters = parameters
        parameters_count = parameters.count
        let rtn = syntax.returnClause
        canThrow = syntax.effectSpecifiers?.throwsClause != nil
//        if parameters.contains(where: {$0.type.canThrow}) {
//            canThrow = true
//        }
        returnType = if rtn.type.trimmedDescription != "Void" {
            rtn.type
        } else { nil }
        if rtn.canThrow {
            canThrow = true
        }
       
    }
}

