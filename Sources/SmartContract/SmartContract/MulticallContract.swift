//
//  MulticallContract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct MulticallContract: SmartContract {
    
    var rpc: RpcApi?
    var address: String?
    let contract = GenericSmartContract.Multicall
    
    public init() {
        self.rpc = nil
        self.address = nil
    }
    
    public init(rcp: RpcApi, address: String) {
        self.rpc = rcp
        self.address = address
    }
    
    public struct Call: ABIEncodable {
        public let address: EthereumAddress
        public let bytes: Data
        public var output: [ABIRawType] = []
        public var result: [ABIDecodable] = []
        
        public func encode(as type: ABIRawType) throws -> Data {
            guard case .tuple = type else {
                throw ABIEncoderError.typeMismatch(self, type)
            }
            return try ABIEncoder.encodeDynamic((.address, address), (.dynamicBytes, bytes))
        }
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
            calls[index].result = try ABIDecoder.decodeDynamicOutput(types: calls[index].output, data: bytesArray[index])
        }
        return (values[0] as! BigUInt, bytesArray)
    }
    
    public func aggregateAbi(_ calls: [Call]) throws -> Data {
        var data = try contract.function("aggregate").signatureData()
        data += try ABIEncoder.encodeDynamic(arrayOf: .tuple(types: [.address, .dynamicBytes]), values: calls)
        return data
    }
    
}
