//
//  BigInt+ABI.swift
//  
//
//  Created by Yuri on 31.05.2023.
//
import Foundation
import BigInt

extension BigInt {
    
    func abiEncode(bits: Int) -> Data {
        let size = (bits + 7) / 8
        var bytes = [UInt8](repeating: 0, count: size)
        
        for i in 0..<size {
            bytes[i] = UInt8(truncatingIfNeeded: words[i])
        }
        
        return Data(bytes)
    }
    
    static func fromTwosComplement(data: Data) -> BigInt {
        let isPositive = ((data[0] & 128) >> 7) == 0
        if isPositive {
            let magnitude = BigUInt(data)
            return BigInt(magnitude)
        } else {
            let MAX = (BigUInt(1) << (data.count*8))
            let magnitude = MAX - BigUInt(data)
            let bigint = BigInt(0) - BigInt(magnitude)
            return bigint
        }
    }
}

extension BigUInt {
    
    func abiEncode(bits: Int) -> Data {
        let size = (bits + 7) / 8
        var bytes = [UInt8](repeating: 0, count: size)
        let data = self.serialize()
        
        // Copy the serialized data to the bytes array, considering padding
        let offset = Swift.max(size - data.count, 0)
        let value = data[Swift.max(data.count - size, 0)..<data.count]
        bytes[offset..<size] = ArraySlice(value)
        
        return Data(bytes)
    }
    
}
