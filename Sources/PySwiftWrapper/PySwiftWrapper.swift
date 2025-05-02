import Foundation
import PyWrapperInfo


@attached(peer, names: arbitrary)
public macro PyFunction(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")

@attached(member, names: arbitrary)
public macro PyModule(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftModuleGenerator")

@attached(member, names: arbitrary)
@attached(extension, names: arbitrary)
public macro PyClass(name: String? = nil, unretained: Bool = false, bases: [PyClassBase] = []) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftClassGenerator")



@attached(peer)
public macro PyProperty(readonly: Bool = false) = #externalMacro(module: "PySwiftGenerators", type: "PyPropertyAttribute")

@attached(peer)
public macro PyMethod() = #externalMacro(module: "PySwiftGenerators", type: "PyMethodAttribute")

@attached(peer, names: arbitrary)
public macro PyStaticMethod(name: String? = nil) = #externalMacro(module: "PySwiftGenerators", type: "PySwiftFuncWrapper")
