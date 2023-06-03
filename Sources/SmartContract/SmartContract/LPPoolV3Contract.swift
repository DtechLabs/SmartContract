//
//  LPPoolV3Contract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//

import Foundation

public enum LPPoolV3Contract {
    
    private static let contract = GenericSmartContract.LPPoolV3
    
    /// The first of the two tokens of the pool, sorted by address
    /// - Returns: The token0 contract address **EthereumAddress**
    public static func token0() throws -> String {
        try contract.function("token0").encode()
    }
    
    /// The second of the two tokens of the pool, sorted by address
    /// - Returns: The token1 contract address **EthereumAddress**
    public static func token1() throws -> String {
        try contract.function("token1").encode()
    }
    
    /// The pool's fee in hundredths of a bip, i.e. 1e-6
    /// - Returns: The fee **BigUInt**
    public static func fee() throws -> String {
        try contract.function("fee").encode()
    }
    
    /// The contract that deployed the pool, which must adhere to the IUniswapV3Factory
    /// - Returns: The contract address **EthereumAddress**
    public static func factory() throws -> String {
        try contract.function("factory").encode()
    }
    
}
