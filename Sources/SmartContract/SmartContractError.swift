//
//  SmartContractError.swift
//  
//
//  Created by Yuri on 30.05.2023.
//

import Foundation

public enum SmartContractError: Error {
    
    case jsonNotFound
    case invalidJson
    case invalidFunctionName(String)
    case invalidSignature
    
    case wrongValue(Any, ABIRawType)
    case unsupportedType(ABIRawType)
    case invalidInputsCount(Int)
    case rawTypeParser(String)
    case invalidData(String)
    case typeMismatch
    case contractOrRpcDidNotSet
}

func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}

extension SmartContractError: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
    
}
