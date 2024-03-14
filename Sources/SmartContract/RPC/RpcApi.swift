//
//  RpcApi.swift
// SmartContract Framework
//
// Created by Yury Dryhin aka DTechLabs on 02.06.2023.
// email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/
//

import Foundation

/// `RpcApi` is a very simple interface that should be implemented  to interact with a blockchain node's.
/// Implementing this protocol allows library  to make calls to smart contracts or query blockchain data.
public protocol RpcApi {
    
    /// n asynchronous method that wrapped an RPC's  `eth_call` to a specified address with the given data, expecting a response of type Result that conforms to Codable.
    /// This method expect a return value, such as querying a smart contract's state.
    func call<Result: Codable>(to: String, data: Data) async throws -> Result
    
    /// An asynchronous method that wrapped an RPC's  `eth_call` to a specified address with the given data but does not expect a return value.
    /// This method can be used for sending transactions that change the state of the blockchain.
    func call(to: String, data: Data) async throws
    
}
