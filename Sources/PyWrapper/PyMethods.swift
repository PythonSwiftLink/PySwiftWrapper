//
//  PyMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax


public class PyMethods {
    
    var cls: String
    var input: [FunctionDeclSyntax]
    
    public init(cls: String, input: [FunctionDeclSyntax]) {
        self.cls = cls
        self.input = input
    }
    
}

extension PyMethods {
    
    fileprivate var arrayElements: ArrayElementListSyntax {
        
        return .init {
            for f in input {
                ArrayElementSyntax(leadingTrivia: .newline, expression: PyMethodDefGenerator(cls: cls ,f: f).method)
            }
            ArrayElementSyntax(leadingTrivia: .newline, expression: "PyMethodDef()".expr)
        }
    }
    
    fileprivate var initializer: InitializerClauseSyntax {
        .init(value: ArrayExprSyntax(elements: arrayElements, rightSquare: .rightSquareToken(leadingTrivia: .newline)))
    }
    
    public var output: DeclSyntax {
        .init(VariableDeclSyntax(modifiers: [.fileprivate, .static], .var, name: "PyMethodDefs", type: .init(type: "[PyMethodDef]".typeSyntax()), initializer: initializer))
        
    }
}



