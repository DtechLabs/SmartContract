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
    
    public var name: String { abi.name }
    public var inputs: [ABIFunction.Input] { abi.inputs }
    public var outputs: [ABIFunction.Output] { abi.outputs }
    
    public  init(abi: ABIFunction) {
        self.abi = abi
    }
    
    public func encode() throws -> Data {
        try signatureData()
    }

    public func encode(param: ABIEncodable) throws -> Data {
        try encode(params: [param])
    }
    
    public func encode(params: [ABIEncodable]) throws -> Data {
        var encoded = try signatureData()
        
        guard params.count == inputs.count else {
            throw SmartContractError.invalidInputsCount(params.count)
        }
        
        if params.count == 0 {
            return encoded
        }
        
        if isFixedSize {
            for (index, type) in inputs.enumerated() {
                let data = try params[index].encode(as: type.type)
                encoded += data
            }
        } else {
            let items = zip(inputs.map { $0.type }, params).map { ($0, $1) }
            encoded += try ABIEncoder.encodeDynamic(items)
        }
        return encoded
    }
    
    public var methodName: String {
        let typeNames = inputs.map {
            if case .tuple = $0.type {
                guard let internalTypes = $0.components?.map({ $0.type }) else {
                    assertionFailure("Should be structure definition")
                    return ""
                }
                return "(" + internalTypes.map { $0.description }.joined(separator: ",") + ")[]"
            } else {
                return $0.type.description
            }
        }
        return name + "(" + typeNames.joined(separator: ",") + ")"
    }
    
    public func signature() throws -> String {
        guard let data = methodName.data(using: .utf8) else {
            throw SmartContractError.invalidSignature
        }
        return data.web3.keccak256.prefix(4).web3.hexString
    }
    
    var isFixedSize: Bool {
        for input in inputs {
            if !input.type.isFixedSize { return false }
        }
        return true
    }
    
    func signatureData() throws -> Data {
        guard let data = methodName.data(using: .utf8) else {
            throw SmartContractError.invalidSignature
        }
        return data.web3.keccak256.prefix(4)
    }
    
    public func decodeOutput(_ rawAnswer: String) throws -> [ABIDecodable] {
        guard let data = Data(hex: rawAnswer) else {
            throw SmartContractError.invalidData(rawAnswer)
        }
        let types = outputs.map { $0.type }
        let isDynamic = !types.filter { !$0.isFixedSize }.isEmpty
        guard !data.isEmpty else {
            throw SmartContractError.invalidData(rawAnswer)
        }
        return try isDynamic ? ABIDecoder.decodeDynamicOutput(types: types, data: data) : ABIDecoder.decodeOutput(types: types, data: data)
    }
    
    public func decodeResult(_ rawAnswer: String) throws -> SmartContractResult {
        try SmartContractResult(
            values: try decodeOutput(rawAnswer),
            outputs: outputs
        )
    }

    public func decode(_ rawAnswer: String) throws -> [ABIValue] {
        guard let data = Data(hex: rawAnswer) else {
            throw SmartContractError.invalidData(rawAnswer)
        }
        
        let values = try ABIDecoder.decode(types: outputs.map { $0.type }, data: data)
        return values
    }
    
}
