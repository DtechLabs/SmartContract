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
    
    public struct Call: ABIEncodable {
        public let address: EthereumAddress
        public let bytes: Data
        
        public func encode(as type: ABIRawType) throws -> Data {
            guard case .tuple = type else {
                throw ABIEncoderError.typeMismatch(self, type)
            }
            return try ABIEncoder.encodeDynamic((.address, address), (.dynamicBytes, bytes))
        }
    }
    
    public func aggregateAbi(_ calls: [Call]) throws -> String {
        var data = try contract.function("aggregate").signatureData()
        data += try ABIEncoder.encodeDynamic(arrayOf: .tuple(types: [.address, .dynamicBytes]), values: calls)
        return data.hexString
    }
    
}
