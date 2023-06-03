//
//  ABIValue.swift
//  
//
//  Created by Yuri on 01.06.2023.
//
import Foundation
import BigInt

public struct ABIValue {
    
    let value: Any
    let rawType: ABIRawType
    
    public func bigUInt() throws -> BigUInt {
        guard case .uint = rawType, let value = value as? BigUInt else {
            throw SmartContractError.typeMismatch
        }
        return value
    }
    
    public func address() throws -> EthereumAddress {
        guard case .address = rawType, let value = value as? EthereumAddress else {
            throw SmartContractError.typeMismatch
        }
        return value
    }
    
    public func string() throws -> String {
        guard case .string = rawType, let value = value as? String else {
            throw SmartContractError.typeMismatch
        }
        return value
    }
    
    public func bytes() throws -> Data {
        guard case .bytes = rawType, let value = value as? Data else {
            throw SmartContractError.typeMismatch
        }
        return value
    }
    
    public func bigInt() throws -> BigInt {
        guard case .int = rawType, let value = value as? BigInt else {
            throw SmartContractError.typeMismatch
        }
        return value
    }
    
    public func array() throws -> [ABIValue] {
        guard case .array(let type, _) = rawType else {
            throw SmartContractError.typeMismatch
        }
        switch type {
            case .uint(let bits):
                return try array(type: .uint(bits: bits), elementType: BigUInt.self)
            case .int(let bits):
                return try array(type: .int(bits: bits), elementType: BigInt.self)
            case .address:
                return try array(type: .address, elementType: EthereumAddress.self)
            case .string:
                return try array(type: .string, elementType: String.self)
            case .bool:
                return try array(type: .bool, elementType: BigUInt.self)
            case .bytes(let bits):
                return try array(type: .bytes(bits: bits), elementType: Data.self)
            default:
                throw SmartContractError.typeMismatch
        }
    }
    
    private func array<T>(type: ABIRawType, elementType: T.Type) throws -> [ABIValue] {
        guard let value = value as? [Any] else {
            throw SmartContractError.typeMismatch
        }
        let array = value.compactMap { $0 as? T }
        guard array.count == value.count else {
            throw SmartContractError.typeMismatch
        }
        return array.map { ABIValue(value: $0, rawType: type) }
    }
}
