//
//  MulticallContract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//

import Foundation

public struct MulticallContract {
    
    private let contract = GenericSmartContract.Multicall
    
    public struct Call {
        public let address: EthereumAddress
        public let bytes: Data
    }
    
    public func aggregateAbi(_ calls: [Call]) throws -> String {
        try contract.function("aggregate").encode(calls)
    }
    
}
