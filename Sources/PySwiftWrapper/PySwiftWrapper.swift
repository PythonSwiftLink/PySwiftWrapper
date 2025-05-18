import Foundation
import PyWrapperInfo


@attached(peer, names: arbitrary)
public macro PyFunction(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")

@attached(member, names: arbitrary)
@attached(extension, names: arbitrary)
public macro PyModule(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftModuleGenerator")

@attached(member, names: arbitrary)
@attached(
    extension,
    conformances:
        PyClassProtocol,
    names: arbitrary
)
@attached(memberAttribute)
public macro PyClass(name: String? = nil, unretained: Bool = false, bases: [PyClassBase] = []) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")

@attached(member, names: arbitrary)
public macro PyClassByExtension(name: String? = nil, unretained: Bool = false, bases: [PyClassBase] = [], expr: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")


@attached(peer)
public macro PyProperty(readonly: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PyPropertyAttribute")

@attached(peer)
public macro PyPropertyEx(expr: String, readonly: Bool = false, target: AnyObject.Type) = #externalMacro(module: "PySwiftGenerators", type: "PyPropertyAttribute")


@attached(peer)
public macro PyMethod() = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")

@freestanding(declaration, names: arbitrary)
public macro PyWrapCode(expr: String, target: AnyObject.Type) = #externalMacro(module: "PySwiftGenerators", type: "PeerDummy")


@attached(peer, names: arbitrary)
public macro PyStaticMethod(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")

@attached(member, names: arbitrary)
public macro ImportableModules(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")


@attached(body)
public macro PyCall(name: String? = nil, gil: Bool = true) = #externalMacro(module: "PySwiftGenerators", type: "PyCallFiller")

@attached(member, names: arbitrary)
public macro PyCallback(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PyCallbackGenerator")

@freestanding(expression)
public macro ExtractPySwiftObject() = #externalMacro(module: "PySwiftGenerators", type: "ExtractPySwiftObject")

@freestanding(expression)
public macro withNoGIL(code: @escaping () -> Void) = #externalMacro(module: "PySwiftGenerators", type: "AttachedTestMacro")






public protocol PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { get }
    static var modules: [PyModuleProtocol] { get }
}

public extension PyModuleProtocol {
    static var py_classes: [(PyClassProtocol & AnyObject).Type] { [] }
    static var modules: [PyModuleProtocol] { [] }
}

public protocol PyClassProtocol {
    
}
