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
    
    public init(values: [ABIDecodable], names: [String]) {
        self.values = Dictionary(uniqueKeysWithValues: zip(names, values))
    }
    
    public init(value: ABIDecodable) {
        self.values = ["value": value]
    }
    
    public subscript<T: ABIDecodable>(dynamicMember name: String) -> T? {
        return values[name] as? T
    }
    
}
