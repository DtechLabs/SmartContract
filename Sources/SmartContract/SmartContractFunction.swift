//
//  SmartContractFunction.swift
//  
//
//  Created by Yuri on 30.05.2023.
//
import Foundation
import BigInt

public struct SmartContractFunction {
    
    let abi: ABIFunction
    var params: [Any] = []
    
    public var name: String { abi.name }
    public var inputs: [ABIFunction.Input] { abi.inputs }
    public var outputs: [ABIFunction.Output] { abi.outputs }
    
    public  init(abi: ABIFunction, params: Any...) {
        self.abi = abi
        self.params = params
    }
    
    public func encode() throws -> String {
        try signature()
    }
    
    public func encode(_ params: Any...) throws -> String {
        let signature = try signature()
        let data = try encodeParams(params)
            .map { $0.toHexString()}
            .joined()
        return signature + data
    }
    
    public var methodName: String {
        let typeNames = inputs.map { $0.type.description }
        return name + "(" + typeNames.joined(separator: ",") + ")"
    }
    
    public func signature() throws -> String {
        guard let data = methodName.data(using: .utf8) else {
            throw SmartContractError.invalidSignature
        }
        return data.web3.keccak256.prefix(4).web3.hexString
    }
    
    private func signatureData() throws -> Data {
        guard let data = methodName.data(using: .utf8) else {
            throw SmartContractError.invalidSignature
        }
        return data.web3.keccak256.prefix(4)
    }
    
    private func encodeParams(_ params: Any...) throws -> [Data] {
        guard params.count == inputs.count else {
            throw SmartContractError.invalidInputsCount(params.count)
        }
        var result: [Data] = []
        for (index, type) in inputs.enumerated() {
            result.append(try encode(params[index], of: type.type))
        }
        return result
    }
    
    private func encode(_ value: Any, of type: ABIRawType) throws -> Data {
        if type.isSignedInteger {
            if type.bitsCount > 64 {
                guard let bigInteger = value as? BigInt else {
                    throw SmartContractError.wrongValue(value, type)
                }
                return bigInteger.abiEncode(bits: type.bitsCount)
            } else {
                guard
                    let intValue = value as? Int,
                    let bigInteger = BigInt(exactly: intValue)
                else {
                    throw SmartContractError.wrongValue(value, type)
                }
                return bigInteger.abiEncode(bits: type.bitsCount)
            }
        } else if type.isUnsignedInteger {
            if type.bitsCount > 64 {
                guard let bigInteger = value as? BigUInt else {
                    throw SmartContractError.wrongValue(value, type)
                }
                return bigInteger.abiEncode(bits: type.bitsCount)
            } else {
                guard
                    let intValue = value as? UInt,
                    let bigInteger = BigUInt(exactly: intValue)
                else {
                    throw SmartContractError.wrongValue(value, type)
                }
                return bigInteger.abiEncode(bits: type.bitsCount)
            }
        } else {
            switch type {
                case .bool:
                    guard let boolValue = value as? Bool else {
                        throw SmartContractError.wrongValue(value, type)
                    }
                    let intValue = boolValue ? 1 : 0
                    return BigInt(intValue).abiEncode(bits: 256)
                case .address:
                    guard
                        let addressValue = value as? String, addressValue.hasPrefix("0x"),
                        let data = EthereumAddress(addressValue)?.abiData
                    else {
                        throw SmartContractError.wrongValue(value, type)
                    }
                    return data
                default:
                    throw SmartContractError.unsupportedType(type)
            }
        }
    }

    public func decode(_ rawAnswer: String) throws -> [ABIValue] {
        guard let data = Data(hex: rawAnswer) else {
            throw SmartContractError.invalidData(rawAnswer)
        }
        
        let values = try ABIDecoder.decode(types: outputs.map { $0.type }, data: data)
        return values
    }
    
}
