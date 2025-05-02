//
//  PyWrapper.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 30/04/2025.
//

import SwiftSyntax


extension LabeledExprSyntax {
    var newLineTab: Self { self.with(\.trailingComma, .commaToken(trailingTrivia: .newline))}
    var newLine: Self { self.with(\.trailingComma, .commaToken(trailingTrivia: .newline))}
}

extension String {
    var `import`: ImportDeclSyntax {
//        .init(path: .init(itemsBuilder: {
//            .init(name: .identifier(self))
//        }))
        .init(path: .init { .init(name: .identifier(self)) } )
    }
    
    var expr: ExprSyntax { .init(stringLiteral: self) }
    
//    var inheritanceType: InheritedTypeSyntax {
//        //        InheritedTypeSyntax(typeName: SimpleTypeIdentifier(stringLiteral: self))
//        .init(type: SimpleTypeIdentifierSyntax(name: .identifier(self)))
//    }
    func cString() -> FunctionCallExprSyntax {
        .cString(self)
    }
    
    public func typeSyntax() -> TypeSyntax {
        .init(stringLiteral: self)
    }
    public var inheritanceType: InheritedTypeSyntax {
        InheritedTypeSyntax(type: typeSyntax() )
    }
}


extension ExprSyntax {
    init(nilOrExpression exp: ExprSyntaxProtocol?) {
        if let exp = exp {
            self.init(fromProtocol: exp)
        } else {
            self.init(fromProtocol: NilLiteralExprSyntax())
        }
        
    }
    
}
extension FunctionCallExprSyntax {
    static func cString(_ string: String) -> Self {
        return .init(callee: DeclReferenceExprSyntax(baseName: .identifier("cString"))) {
            LabeledExprSyntax(expression: StringLiteralExprSyntax(content: string))
        }
    }
}


extension FunctionParameterListSyntax {
    var canThrow: Bool {
        self.contains(where: \.canThrow)
    }
}

extension Array where Element == FunctionParameterSyntax {
    var canThrow: Bool {
        self.contains(where: \.canThrow)
    }
}

extension FunctionParameterSyntax {
    var canThrow: Bool {
        switch type.description {
        case "PyPointer": false
        default: true
        }
        
    }
}

extension FunctionDeclSyntax {
    var `throws`: Bool {
        signature.effectSpecifiers?.throwsSpecifier != nil
    }
}
