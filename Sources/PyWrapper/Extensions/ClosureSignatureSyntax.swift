//
//  ClosureSignatureSyntax.swift
//  PySwiftWrapper
//
//  Created by CodeBuilder on 02/05/2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder

fileprivate extension ReturnClauseSyntax {
    static var pyPointer: Self { .init(type: TypeSyntax(stringLiteral: "PyPointer?"))}
    static var optPyPointer: Self { .init(type: TypeSyntax(stringLiteral: "PyPointer?"))}
    static var int32: Self { .init(type: TypeSyntax(stringLiteral: "Int32"))}
    static var int: Self { .init(type: TypeSyntax(stringLiteral: "Int"))}
    static var pySendResult: Self { .init(type: TypeSyntax(stringLiteral: "PySendResult"))}
}

extension ClosureSignatureSyntax {
    static var allocfunc: Self {
        .init(parameterClause: .parameterClause(.allocfunc), returnClause: .pyPointer)
    }
    
    static var destructor: Self {
        .init(parameterClause: .parameterClause(.destructor), returnClause: nil)
    }
    
    static var freefunc: Self {
        .init(parameterClause: .parameterClause(.freefunc), returnClause: nil)
    }
    
    static var traverseproc: Self {
        .init(parameterClause: .parameterClause(.traverseproc), returnClause: .int32)
    }
    
    static var newfunc: Self {
        .init(parameterClause: .parameterClause(.newfunc), returnClause: .pyPointer)
    }
    
    static var initproc: Self {
        .init(parameterClause: .parameterClause(.initproc), returnClause: .int32)
    }
    
    static var reprfunc: Self {
        .init(parameterClause: .parameterClause(.reprfunc), returnClause: .pyPointer)
    }
    
    static var getattrfunc: Self {
        .init(parameterClause: .parameterClause(.getattrfunc), returnClause: .pyPointer)
    }
    
    static var setattrfunc: Self {
        .init(parameterClause: .parameterClause(.setattrfunc), returnClause: .int32)
    }
    
    static var getattrofunc: Self {
        .init(parameterClause: .parameterClause(.getattrofunc), returnClause: .pyPointer)
    }
    
    static var setattrofunc: Self {
        .init(parameterClause: .parameterClause(.setattrofunc), returnClause: .int32)
    }
    
    static var descrgetfunc: Self {
        .init(parameterClause: .parameterClause(.descrgetfunc), returnClause: .pyPointer)
    }
    
    static var descrsetfunc: Self {
        .init(parameterClause: .parameterClause(.descrsetfunc), returnClause: .int32)
    }
    
    static var hashfunc: Self {
        .init(parameterClause: .parameterClause(.hashfunc), returnClause: .int)
    }
    
    static var richcmpfunc: Self {
        .init(parameterClause: .parameterClause(.richcmpfunc), returnClause: .pyPointer)
    }
    
    static var getiterfunc: Self {
        .init(parameterClause: .parameterClause(.getiterfunc), returnClause: .pyPointer)
    }
    
    static var iternextfunc: Self {
        .init(parameterClause: .parameterClause(.iternextfunc), returnClause: .pyPointer)
    }
    
    static var lenfunc: Self {
        .init(parameterClause: .parameterClause(.lenfunc), returnClause: .int)
    }
    
    static var getbufferproc: Self {
        .init(parameterClause: .parameterClause(.getbufferproc), returnClause: .int32)
    }
    
    static var releasebufferproc: Self {
        .init(parameterClause: .parameterClause(.releasebufferproc))
    }
    
    static var inquiry: Self {
        .init(parameterClause: .parameterClause(.inquiry), returnClause: .int32)
    }
    
    static var unaryfunc: Self {
        .init(parameterClause: .parameterClause(.unaryfunc), returnClause: .pyPointer)
    }
    
    static var binaryfunc: Self {
        .init(parameterClause: .parameterClause(.binaryfunc), returnClause: .pyPointer)
    }
    
    static var ternaryfunc: Self {
        .init(parameterClause: .parameterClause(.ternaryfunc), returnClause: .pyPointer)
    }
    
    static var ssizeargfunc: Self {
        .init(parameterClause: .parameterClause(.ssizeargfunc), returnClause: .pyPointer)
    }
    
    static var ssizeobjargproc: Self {
        .init(parameterClause: .parameterClause(.ssizeobjargproc), returnClause: .int32)
    }
    
    static var objobjproc: Self {
        .init(parameterClause: .parameterClause(.objobjproc), returnClause: .int32)
    }
    
    static var objobjargproc: Self {
        .init(parameterClause: .parameterClause(.objobjargproc), returnClause: .int32)
    }
    
    static var sendfunc: Self {
        .init(parameterClause: .parameterClause(.sendfunc), returnClause: .pySendResult)
    }
    
    static var void: Self {
        .init(parameterClause: .parameterClause(.void))
    }
    
    static var getset_getter: Self {
        .init(parameterClause: .parameterClause(.getset_getter), returnClause: .pyPointer)
    }
    
    static var getset_setter: Self {
        .init(parameterClause: .parameterClause(.getset_setter), returnClause: .int32)
    }
}

extension ClosureParameterClauseSyntax {
    fileprivate static var __self__: ClosureParameterSyntax { "__self__" }
    
    fileprivate static var _type: ClosureParameterSyntax { "type" }
    
    fileprivate static var size: ClosureParameterSyntax { "size" }
    
    fileprivate static var __arg__: ClosureParameterSyntax { "__arg__" }
    
    fileprivate static var __args__: ClosureParameterSyntax { "__args__" }
    
    fileprivate static var kw: ClosureParameterSyntax { "kw" }
    
    fileprivate static var raw: ClosureParameterSyntax { "raw" }
    
    fileprivate static func new(@ClosureParameterListBuilder itemsBuilder: () -> ClosureParameterListSyntax) -> Self {
        .init(parameters: .init(itemsBuilder: itemsBuilder))
    }
}

extension ClosureParameterClauseSyntax {
    
    static var allocfunc: Self { .new {
        _type
        size
    }}
    
    static var destructor: Self { .new { __self__ } }
    
    static var freefunc: Self { .new { raw } }
    
    static var traverseproc: Self { .new {
        __self__
        "visit"
        raw
    }}
    
    static var newfunc: Self { .new {
        __self__
        __args__
        kw
    }}
    
    static var initproc: Self { .new {
        __self__
        __args__
        kw
    }}
    
    static var reprfunc: Self { .new {
        __self__
    }}
    
    static var getattrfunc: Self { .new {
    }}
    
    static var setattrfunc: Self { .new {
        
    }}
    
    static var getattrofunc: Self { .new {
        __self__
        "key"
    }}
    
    static var setattrofunc: Self { .new {
        __self__
        "key"
        "newValue"
    }}
    
    static var descrgetfunc: Self { .new {
        __self__
        "key"
    }}
    
    static var descrsetfunc: Self { .new {
        __self__
        "key"
        "newValue"
    }}
    
    static var hashfunc: Self { .new {
        __self__
    }}
    
    static var richcmpfunc: Self { .new {
        "l"
        "r"
        "cmp"
    }}
    
    static var getiterfunc: Self { .new {
        __self__
    }}
    
    static var iternextfunc: Self { .new {
        __self__
    }}
    
    static var lenfunc: Self { .new {
        __self__
    }}
    
    static var getbufferproc: Self { .new {
        __self__
        "buffer"
    }}
    
    static var releasebufferproc: Self { .new {
        __self__
        "buffer"
    }}
    
    static var inquiry: Self { .new {
        __self__
    }}
    
    static var unaryfunc: Self { .new {
        __self__
    }}
    
    static var binaryfunc: Self { .new {
        __self__
        "o"
    }}
    
    static var ternaryfunc: Self { .new {
        __self__
        "o"
        kw
    }}
    
    static var ssizeargfunc: Self { .new {
        __self__
        "i"
    }}
    
    static var ssizeobjargproc: Self { .new {
        __self__
        "i"
        "o"
    }}
    
    static var objobjproc: Self { .new {
        __self__
        "x"
    }}
    
    static var objobjargproc: Self { .new {
        __self__
        "x"
        "y"
    }}
    
    static var sendfunc: Self { .new {
        __self__
        __args__
        kw
    }}
    
    static var void: Self { .new {
        "_"
    }}
    
    static var getset_getter: Self { .new {
        __self__
        "clossure"
    }}
    
    static var getset_setter: Self { .new {
        __self__
        "clossure"
        "newValue"
    }}
}
