//
//  ClosureExprSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder


extension ClosureExprSyntax {
    static func allocfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
      .init(signature: .allocfunc, statementsBuilder: itemsBuilder)
    }
    
    static func destructor(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .destructor, statementsBuilder: itemsBuilder)
    }
    
    static func freefunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .freefunc, statementsBuilder: itemsBuilder)
    }
    
    static func traverseproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .traverseproc, statementsBuilder: itemsBuilder)
    }
    
    static func newfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .newfunc, statementsBuilder: itemsBuilder)
    }
      
    static func initproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .initproc, statementsBuilder: itemsBuilder)
    }
    
    static func reprfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .reprfunc, statementsBuilder: itemsBuilder)
    }
    
    static func getattrfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .getattrfunc, statementsBuilder: itemsBuilder)
    }
    
    static func setattrfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .setattrfunc, statementsBuilder: itemsBuilder)
    }
    
    static func getattrofunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .getattrofunc, statementsBuilder: itemsBuilder)
    }
    
    static func setattrofunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .setattrofunc, statementsBuilder: itemsBuilder)
    }
    
    static func descrgetfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .descrgetfunc, statementsBuilder: itemsBuilder)
    }
    
    static func descrsetfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .descrsetfunc, statementsBuilder: itemsBuilder)
    }
    
    static func hashfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .hashfunc, statementsBuilder: itemsBuilder)
    }
    
    static func richcmpfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .richcmpfunc, statementsBuilder: itemsBuilder)
    }
    
    static func getiterfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .getiterfunc, statementsBuilder: itemsBuilder)
    }
    
    static func iternextfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .iternextfunc, statementsBuilder: itemsBuilder)
    }
    
    static func lenfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .lenfunc, statementsBuilder: itemsBuilder)
    }
    
    static func getbufferproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .getbufferproc, statementsBuilder: itemsBuilder)
    }
    
    static func releasebufferproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .releasebufferproc, statementsBuilder: itemsBuilder)
    }
    
    static func inquiry(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .inquiry, statementsBuilder: itemsBuilder)
    }
    
    static func unaryfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .unaryfunc, statementsBuilder: itemsBuilder)
    }
    
    static func binaryfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .binaryfunc, statementsBuilder: itemsBuilder)
    }
    
    static func ternaryfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .ternaryfunc, statementsBuilder: itemsBuilder)
    }
    
    static func ssizeargfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .ssizeargfunc, statementsBuilder: itemsBuilder)
    }
    
    static func ssizeobjargproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .ssizeobjargproc, statementsBuilder: itemsBuilder)
    }
    
    static func objobjproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .objobjproc, statementsBuilder: itemsBuilder)
    }
    
    static func objobjargproc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .objobjargproc, statementsBuilder: itemsBuilder)
    }
    
    static func sendfunc(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .sendfunc, statementsBuilder: itemsBuilder)
    }
    
    static func void(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .void, statementsBuilder: itemsBuilder)
    }
    
    static func getset_getter(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .getset_getter, statementsBuilder: itemsBuilder)
    }
    
    static func getset_setter(@CodeBlockItemListBuilder itemsBuilder: () -> CodeBlockItemListSyntax) -> Self {
        .init(signature: .getset_setter, statementsBuilder: itemsBuilder)
    }
}
