
import Foundation
import SwiftSyntax


public extension PyWrap {
	
	struct BoolType: CustomStringConvertible {
		
        let parameter: FunctionParameterSyntax
        let index: Int?
		
        init(parameter: FunctionParameterSyntax, index: Int?) {
            self.parameter = parameter
            self.index = index
        }
		
        var extract: String? {
            
            return nil
        }
        
        func cast() -> String {
            if let index {
                return "try PyCast(from: args[\(index)])"
            }
            
            
            return "try PyCast(from: arg)"
        }
		
		public var description: String { "Bool" }
		
		public var string: String { "Bool" }
		
	}
	
}




