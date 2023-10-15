//
//  SmartContractResult.swift
//  
//
//  Created by Yuri on 16.08.2023.
//

import Foundation

@dynamicMemberLookup
public struct SmartContractResult {
    
    let values: [String: ABIDecodable]
    let outputs: [ABIFunction.Output]
    
    public init(values: [ABIDecodable], outputs: [ABIFunction.Output]) throws {
        guard outputs.count == values.count else {
            throw SmartContractError.wrongFunctionOutputsCount
        }
        
        self.outputs = outputs
        
        if outputs.count == 1 && outputs.first?.name == "" {
            self.values = ["value": values[0]]
        } else {
            self.values = Dictionary(uniqueKeysWithValues: zip(outputs.map { $0.name }, values))
        }
    }
    
    public subscript<T: ABIDecodable>(dynamicMember name: String) -> T? {
        return values[name] as? T
    }
    
}
