//
//  ABIDecodable.swift
//  
//
//  Created by Yuri on 06.06.2023.
//
import Foundation
import BigInt

public enum ABIDecoderError: Error {
    
    case missedDataOrCorrupt
    case wrongValue
    case unsupportedType(ABIRawType)
    case shouldBeFixedSize
    
}

public protocol ABIDecodable {
    
    /// Decodes a single value from the data with a given offset.
    ///  - Note: This function does not validate the size of the data, which could potentially lead to a crash.
    /// - Parameters:
    ///   - rawType: The ABIRawType from ABIFunction.Output.
    ///   - data: The output data.
    ///   - offset: The offset of the element from the beginning of the data.
    /// - Returns: The decoded value.
    static func decode(as rawType: ABIRawType, from data: Data, offset: inout UInt) throws -> Self
    
}

public extension ABIDecodable {
    
    static func setLengthPadding(_ length: UInt, to padding: UInt = EVMWordSize) -> UInt {
        length % padding == 0 ? length : (length + (padding - length % padding))
    }
    
}

// MARK: BigUInt
extension BigUInt: ABIDecodable {
    
    public static func decode(as rawType: ABIRawType, from data: Data, offset: inout UInt) throws -> BigUInt {
        let data = data[offset..<offset+EVMWordSize]
        guard let value = BigUInt(hex: data.hexString) else {
            throw ABIDecoderError.wrongValue
        }
        offset += EVMWordSize
        return value
    }
    
}

// MARK: BigInt
extension BigInt: ABIDecodable {
    
    public static func decode(as rawType: ABIRawType = .int(bits: 256), from data: Data, offset: inout UInt) throws -> BigInt {
        let data = data[offset..<offset+EVMWordSize]
        guard let value = BigInt(hex: data.hexString) else {
            throw ABIDecoderError.wrongValue
        }
        offset += EVMWordSize
        return value
    }
    
}

// MARK: Bool
extension Bool: ABIDecodable {
    
    public static func decode(as rawType: ABIRawType = .bool, from data: Data, offset: inout UInt) throws -> Bool {
        let value = try BigUInt.decode(as: .uint256, from: data, offset: &offset)
        guard 0...1 ~= value else {
            throw ABIDecoderError.wrongValue
        }
        offset += EVMWordSize
        return value == 1
    }
    
}

// MARK: Bool
extension String: ABIDecodable {
    
    public static func decode(as rawType: ABIRawType = .string, from data: Data, offset: inout UInt) throws -> String {
        guard data.count > EVMWordSize + offset, let length = UInt(hex: data.prefix(Int(EVMWordSize + offset)).hexString) else {
            throw ABIDecoderError.missedDataOrCorrupt
        }
        
        guard data.count >= offset + EVMWordSize + length else {
            throw ABIDecoderError.missedDataOrCorrupt
        }
        
        let data = data.dropFirst(Int(EVMWordSize)).prefix(Int(length))
        
        guard let value = String(data: data, encoding: .utf8) else {
            throw ABIDecoderError.wrongValue
        }
        offset += EVMWordSize + setLengthPadding(length)
        return value
    }
    
}

// MARK: Ethereum Address
extension EthereumAddress: ABIDecodable {
    
    public static func decode(as rawType: ABIRawType = .address, from data: Data, offset: inout UInt) throws -> EthereumAddress {
        let data = try BigUInt.decode(as: .uint160, from: data, offset: &offset)
        guard let value = EthereumAddress(data.web3.hexString) else {
            throw ABIDecoderError.wrongValue
        }
        
        return value
    }
    
}


// MARK: Data
extension Data: ABIDecodable {
    
    public static func decode(as rawType: ABIRawType, from data: Data, offset: inout UInt) throws -> Data {
        switch rawType {
            case .bytes(let size):
                guard 0 < size, size <= EVMWordSize else {
                    throw SmartContractError.invalidBytesSize(size)
                }
                guard data.count >= offset + UInt(size) else {
                    throw ABIDecoderError.missedDataOrCorrupt
                }
                let value = data[offset ..< offset + UInt(size)]
                offset += setLengthPadding(UInt(size))
                return value
            case .dynamicBytes:
                guard data.count > offset + EVMWordSize else {
                    throw ABIDecoderError.missedDataOrCorrupt
                }
                let size = UInt(try BigUInt.decode(as: .uint256, from: data, offset: &offset))
                guard data.count > offset + size else {
                    throw ABIDecoderError.missedDataOrCorrupt
                }
                let newData = data[offset ..< offset + size]
                offset += setLengthPadding(size)
                return newData
            default:
                throw ABIDecoderError.unsupportedType(rawType)
        }
    }
    
    public func decode(as type: ABIRawType = .dynamicBytes) throws -> Data {
        switch type {
            case .dynamicBytes:
                return try BigUInt(integerLiteral: UInt64(self.count)).encode() + self.rightZeroPadding()
            case .bytes(let size):
                guard 0 < size, size <= 32 else {
                    throw SmartContractError.invalidBytesSize(size)
                }
                return Data(self).rightZeroPadding()
            default:
                throw ABIEncoderError.typeMismatch(self, type)
        }
    }
    
}
