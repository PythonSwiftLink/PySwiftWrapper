//
//  ConvertArgs.swift
//  PySwiftKitMacros
//
//  Created by CodeBuilder on 28/04/2025.
//
import SwiftSyntax

public struct PyWrap {
    
    public enum BaseTypes: String {
        case Int
        case UInt
        case Int32
        case UInt32
        case Int16
        case UInt16
        case Int8
        case UInt8
        case String
        case Data
        case PyPointer
        
        init?(typeSyntax: TypeSyntax) {
            self.init(rawValue: typeSyntax.description)
        }
    }
    
    
}



public func handleTypes(_ t: TypeSyntax,_ index: Int?) -> String {
    switch t {
    case let opt where opt.is(OptionalTypeSyntax.self):
        handleOptionalType(opt.as(OptionalTypeSyntax.self)!, index)
    default:
        if let index {
            "try pyCast(from: __args__, index: \(index))"
        } else {
            "try pyCast(from: __arg__)"
        }
    }
}

private func handleArrayType(_ t: ArrayTypeSyntax,_ index: Int?) -> String {
    "Array<\(t.element.description)>"
}


private func handleOptionalType(_ t: OptionalTypeSyntax, _ index: Int?) -> String {
    if let index {
        "optionalPyCast(from: __args__[\(index)])"
    } else {
        "optionalPyCast(from: __arg__)"
    }
}
