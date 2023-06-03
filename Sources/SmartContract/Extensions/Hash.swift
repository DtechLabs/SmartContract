//
//  Hash.swift
//  
//
//  Created by Yuri on 31.05.2023.
//
import Foundation
import CryptoSwift

public enum Hash {
    
    static func calculateKeccak256Hash(data: Data) -> Data {
        let hash = data.sha3(.keccak256)
        return Data(hash)
    }
    
}
