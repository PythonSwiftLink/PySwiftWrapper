//
//  Extensions.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 01/05/2025.
//

import SwiftSyntax



extension AttributeListSyntax.Element {
    var isPyFunction: Bool {
        trimmedDescription.contains("@PyFunction")
        
    }
    var isPyMethod: Bool {
        trimmedDescription.contains("@PyMethod")
    }
    var isPyInit: Bool {
        trimmedDescription.contains("@PyInit")
    }
}

extension AttributeListSyntax {
    var isPyFunction: Bool {
        contains(where: \.isPyFunction)
    }
    var isPyMethod: Bool {
        contains(where: \.isPyMethod)
    }
    var isPyInit: Bool {
        contains(where: \.isPyInit)
    }
}

extension FunctionDeclSyntax {
    var isPyFunction: Bool {
        attributes.isPyFunction
    }
    var isPyMethod: Bool {
        attributes.isPyMethod
    }
    var isPyInit: Bool {
        attributes.isPyInit
    }
}

extension DeclModifierSyntax {
    static var `public`: Self { .init(name: .keyword(.public)) }
    static var `private`: Self { .init(name: .keyword(.private)) }
    static var `fileprivate`: Self { .init(name: .keyword(.fileprivate)) }
    static var `static`: Self { .init(name: .keyword(.static)) }
}


