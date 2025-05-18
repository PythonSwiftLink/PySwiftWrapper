//
//  PyWrapperInfo.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import Foundation

public enum PyClassBase: String, CaseIterable {
    case async
    case sequence
    case mapping
    case buffer
    case number
    case bool
    case int
    case float
    case str
    case repr
    case hash
    
    
}

extension Array where Element == PyClassBase {
    public static var all: Self { PyClassBase.allCases }
}
