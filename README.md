# PySwiftWrapper

swift code
```swift
@PyClass
final class MySwiftType {
    
    @PyProperty
    public var string: String
    
    @PyProperty
    public var value: UInt
    
    init() {
        string = ""
        value = 0
    }
    
    @PyMethod
    func noArgs() {
    }
    
    @PyMethod
    func noArgsThrows() throws {
    }
    
    @PyMethod
    func withArgs(a: Int, b: [Int?], c: String?) {
        print(a,b,c ?? "nil")
    }
    
    @PyMethod
    static func staticFunc(d: [Int:String]) {
        print(d)
    }
    
    @PyMethod
    func return_call() -> String {
        print(a,b,c ?? "nil")
    }
    
    // only @PyMethod decorated functions will be wrapped
    func NotPyFunc() {
        
    }
}

```
generated python api:
```py

class MySwiftType:

    string: str
    value: int

    def __init__(self): ...

    def noArgs(self): ...

    def noArgsThrows(self): ...

    def swiftFunc(self, a: int, b: list[int | None], c: str | None): ...

    @staticmethod
    def staticFunc(d: dict[int, str]): ...

    def return_call(self) -> str: ...
    
```
