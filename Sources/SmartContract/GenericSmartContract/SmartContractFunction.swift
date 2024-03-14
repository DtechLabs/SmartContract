//
//  SmartContractFunction.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 25.08.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/

import Foundation
import BigInt

/// The SmartContractFunction structure provides an  interface to work with an Ethereum smart contract function,
/// encapsulating the function's ABI (Application Binary Interface) details, encoding input parameters, and decoding output results.
///
/// ## Error Handling
/// The structure uses SmartContractError to handle various error scenarios, such as invalid inputs count, invalid signature, and invalid data during encoding or decoding processes.
public struct SmartContractFunction {
    
    /// An instance of ``ABIFunction`` representing the ABI details of the smart contract function.
    public let abi: ABIFunction
    
    /// A string representing the name of the smart contract function
    public var name: String { abi.name }
    /// An array of ``ABIFunction/Input`` representing the input parameters of the function.
    public var inputs: [ABIFunction.Input] { abi.inputs }
    /// An array of ``ABIFunction/Output`` representing the output parameters of the function.
    public var outputs: [ABIFunction.Output] { abi.outputs }
    
    /// Initializes a new SmartContractFunction instance with the specified ABI.
    /// - Parameter abi: The ABI of the smart contract function.
    public  init(abi: ABIFunction) {
        self.abi = abi
    }
    
    /// Encodes the function signature without parameters into Data.
    /// - Returns: The encoded function signature as Data.
    public func encode() throws -> Data {
        try signatureData()
    }

    /// Encodes a single parameter and the function signature into Data.
    /// - Parameter param: A single ``ABIEncodable`` parameter to be encoded.
    /// - Returns: The encoded parameter and function signature as Data.
    public func encode(param: ABIEncodable) throws -> Data {
        try encode(params: [param])
    }
    
    /// Encodes multiple parameters along with the function signature into Data.
    /// - Parameter params: An array of ``ABIEncodable`` parameters to be encoded.
    /// - Returns: The encoded parameters and function signature as Data.
    /// - Throws: SmartContractError.invalidInputsCount if the number of parameters does not match the expected number of inputs.
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
    
    /// The methodName property constructs a unique method identifier by combining the function's name with the types of its input parameters.
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
    
    /// Generates the function signature as a string.
    /// - Returns: The function signature as a String.
    public func signature() throws -> String {
        guard let data = methodName.data(using: .utf8) else {
            throw SmartContractError.invalidSignature
        }
        return data.web3.keccak256.prefix(4).web3.hexString
    }
    
    /// The `isFixedSize` property checks if all input parameters of the function are of fixed size, which influences how parameters are encoded.
    var isFixedSize: Bool {
        for input in inputs {
            if !input.type.isFixedSize { return false }
        }
        return true
    }
    
    /// Generates the first 4 bytes of the Keccak-256 hash of the function's signature, which is used as the function selector in Ethereum transactions.
    func signatureData() throws -> Data {
        guard let data = methodName.data(using: .utf8) else {
            throw SmartContractError.invalidSignature
        }
        return data.web3.keccak256.prefix(4)
    }
    
    /// Decodes the output data from a smart contract function call.
    /// - Parameter rawAnswer: The raw output data as a String.
    /// - Returns: An array of ``ABIDecodable`` representing the decoded output values.
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
    
    /// Decodes the output data into a SmartContractResult.
    /// - Parameter rawAnswer: The raw output data as a String.
    /// - Returns: A ``SmartContractResult`` representing the decoded output values.
    public func decodeResult(_ rawAnswer: String) throws -> SmartContractResult {
        try SmartContractResult(
            values: try decodeOutput(rawAnswer),
            outputs: outputs
        )
    }

    /// Decodes the output data into an array of ``ABIValue``.
    /// - Parameter rawAnswer: The raw output data as a String.
    /// - Returns: An array of ``ABIValue`` representing the decoded output values.
    public func decode(_ rawAnswer: String) throws -> [ABIValue] {
        guard let data = Data(hex: rawAnswer) else {
            throw SmartContractError.invalidData(rawAnswer)
        }
        
        let values = try ABIDecoder.decode(types: outputs.map { $0.type }, data: data)
        return values
    }
    
}
