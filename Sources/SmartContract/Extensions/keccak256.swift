//
//  keccak256.swift
//  
//
//  Created by Yuri on 31.05.2023.
//
import Foundation

public extension Web3Extensions where Base == Data {
    
    var keccak256: Data {
        Hash.calculateKeccak256Hash(data: self.base)
    }
}

public extension Web3Extensions where Base == String {
    
    var keccak256: Data {
        let data = base.data(using: .utf8) ?? Data()
        return data.web3.keccak256
    }
    
    var keccak256fromHex: Data {
        let data = base.web3.hexData!
        return data.web3.keccak256
    }
    
}
