//
//  Web3Extendable.swift
//  
//
//  Created by Yuri on 31.05.2023.
//

import Foundation
import BigInt

public protocol Web3Extendable {
    associatedtype T
    var web3: T { get }
}

public extension Web3Extendable {
    var web3: Web3Extensions<Self> {
        return Web3Extensions(self)
    }
}

public struct Web3Extensions<Base> {
    internal(set) public var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

extension Data: Web3Extendable {}
extension String: Web3Extendable {}
extension BigUInt : Web3Extendable {}
extension BigInt : Web3Extendable {}
extension Int : Web3Extendable {}

// MARK: 
public extension Web3Extensions where Base == String {
    var isNumeric: Bool {
        guard !base.isEmpty else {
            return false
        }
        
        guard !base.starts(with: "-") else {
            return String(base.dropFirst()).web3.isNumeric
        }
        
        return base.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

