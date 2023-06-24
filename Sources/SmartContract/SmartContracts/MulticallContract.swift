//
//  MulticallContract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct MulticallContract: SmartContract {
    
    public var rpc: RpcApi?
    public var address: String?
    public let contract = GenericSmartContract.Multicall
    
    public init() {
        self.rpc = nil
        self.address = nil
    }
    
    public init(rpc: RpcApi, address: String) {
        self.rpc = rpc
        self.address = address
    }
    
    public struct Call: ABIEncodable {
        public let address: EthereumAddress
        public let bytes: Data
        public var output: [ABIFunction.Output] = []
        public var result: [ABIDecodable] = []

        public func encode(as type: ABIRawType) throws -> Data {
            guard case .tuple = type else {
                throw ABIEncoderError.typeMismatch(self, type)
            }
            return try ABIEncoder.encodeDynamic((.address, address), (.dynamicBytes, bytes))
        }
        
        public func getResult<T: ABIDecodable>(_ name: String) throws -> T  {
            guard let index = output.firstIndex(where: { $0.name == name }) else {
                throw ABIDecoderError.unknownOutputName
            }
            
            guard let value = result[index] as? T else {
                throw ABIDecoderError.mismatchTypes(output[index].type, T.self)
            }
            return value
        }
        
        public func getResult<T: ABIDecodable>(by index: Int = 0) throws -> T  {
            guard result.indices.contains(index) else {
                throw ABIDecoderError.resultNotFound(index)
            }
            
            guard let value = result[index] as? T else {
                throw ABIDecoderError.mismatchTypes(output[index].type, T.self)
            }
            return value
        }
    }
    
    public static func call(_ function: SmartContractFunction, address: String) throws -> Call {
        guard let address = EthereumAddress(address) else {
            throw SmartContractError.invalidAddress
        }
        return Call(
            address: address,
            bytes: try function.encode(),
            output: function.outputs
        )
    }
    
    public static func call(_ function: SmartContractFunction, address: String, params: ABIEncodable...) throws -> Call {
        guard let address = EthereumAddress(address) else {
            throw SmartContractError.invalidAddress
        }
        return Call(
            address: address,
            bytes: try function.encode(), // (params),
            output: function.outputs
        )
    }
    
    @discardableResult
    public func aggregate(_ calls: inout [Call]) async throws -> (BigUInt, [Data]) {
        let answer = try await call(aggregateAbi(calls).hexString)
        let values = try MulticallContract().contract.function("aggregate").decodeOutput(answer)
        let bytesArray = values[1] as! [Data]
        guard bytesArray.count == calls.count else {
            throw SmartContractError.invalidData(answer)
        }
        for index in calls.indices {
            calls[index].result = try ABIDecoder.decodeDynamicOutput(types: calls[index].output.map { $0.type }, data: bytesArray[index])
        }
        return (values[0] as! BigUInt, bytesArray)
    }
    
    public func aggregateAbi(_ calls: [Call]) throws -> Data {
        var data = try contract.function("aggregate").signatureData()
        data += try ABIEncoder.encodeDynamic(arrayOf: .tuple(types: [.address, .dynamicBytes]), values: calls)
        return data
    }
    
}
