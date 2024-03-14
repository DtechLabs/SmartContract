//
//  SmartContractError.swift
//  
//
//  Created by Yuri on 30.05.2023.
//

import Foundation

/// The `SmartContractError` enumeration defines a comprehensive set of errors that can occur when interacting with Ethereum smart contracts,
/// particularly in the context of encoding, decoding, calling functions, and setting up smart contracts.
/// Each case in this enumeration provides specific information about the kind of error encountered, making error handling more precise and informative for developers.
public enum SmartContractError: Error {
    
    /// Indicates that the JSON file containing the ABI was not found.
    case jsonNotFound
    /// Indicates that the ABI JSON is malformed or unreadable.
    case invalidJson
    /// The function name provided does not match any function in the ABI.
    case invalidFunctionName(String)
    /// The function signature could not be generated or is invalid.
    case invalidSignature
    /// An invalid type was encountered during processing.
    case invalidType
    /// The function name or arguments provided are invalid.
    case invalidFunctionNameOrArguments
    /// The provided Ethereum address is invalid.
    case invalidAddress
    /// A value does not match the expected type.
    case wrongValue(Any, ABIRawType)
    /// Error parsing a string into an ``ABIRawType``.
    case unsupportedType(ABIRawType)
    /// The number of inputs does not match the expected count.
    case invalidInputsCount(Int)
    /// Error parsing a string into an ``ABIRawType``.
    case rawTypeParser(String)
    /// The provided data is invalid or malformed.
    case invalidData(String)
    /// There is a mismatch between expected and provided types.
    case typeMismatch
    /// Before calling a smart contract function, both RPC and the contract address must be set.
    case contractOrRpcDidNotSet
    /// The function name is missing when dynamically calling a smart contract function.
    case missedFunctionName
    /// The count or type of arguments does not match the function's expectations.
    case wrongFunctionArgumentsCountOrType
    /// The number of function outputs does not match the count defined in the ABI.
    case wrongFunctionOutputsCount
    /// The size of a bytes array is invalid.
    case invalidBytesSize(Int)
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
