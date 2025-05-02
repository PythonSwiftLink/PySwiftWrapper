//
//  PyGetSetMethods.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import Foundation
import SwiftSyntax

struct PyGetSetProperty {
    
    var property: VariableDeclSyntax
    var cls: String
    var typeSyntax: TypeSyntax
    
    init(property: VariableDeclSyntax, cls: String) {
        self.property = property
        self.cls = cls
        self.typeSyntax = property.bindings.last?.as(TypeAnnotationSyntax.self)?.type ?? .pyPointer
        
        
    }
    
}

extension PyGetSetProperty {
    var getter: ClosureExprSyntax {
        .getset_getter {
            
        }
    }
    
    var setter: ClosureExprSyntax {
        .getset_setter {
            
        }
    }
    
    var pyGetSetDef: FunctionCallExprSyntax {
        .init(calledExpression: "PyGetSetDef".expr) {
            
        }
    }
}
