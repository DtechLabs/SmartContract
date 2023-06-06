//
//  ABIEncodable.swift
//  
//
//  Created by Yuri on 05.06.2023.
//
import Foundation
import BigInt

public enum ABIEncoderError: Error {
    
    case typeMismatch(Any, ABIRawType)
    case wrongAddressFormat(String)
    case wrongArrayLength
    case tupleEncodingError
    case shouldByDynamic
}

public protocol ABIEncodable {
    
    func encode(as type: ABIRawType) throws -> Data
 
}

// MARK: BigUInt
extension BigUInt: ABIEncodable {

    public func encode(as type: ABIRawType = .uint256) throws -> Data {
        guard case .uint = type else {
            throw ABIEncoderError.typeMismatch(self, type)
        }

        return abiEncode(bits: 256)
    }
    
}

// MARK: BigInt
extension BigInt: ABIEncodable {
    
    public func encode(as type: ABIRawType = .int(bits: 256)) throws -> Data {
        guard case .int = type else {
            throw ABIEncoderError.typeMismatch(self, type)
        }
        return abiEncode(bits: 256)
    }
    
}

// MARK: Bool
extension Bool: ABIEncodable {
    
    public func encode(as type: ABIRawType) throws -> Data {
        guard case .bool = type else {
            throw ABIEncoderError.typeMismatch(self, type)
        }
        return try BigUInt(self ? 1 : 0).encode(as: .uint256)
    }
    
}

// MARK: EthereumAddress
extension EthereumAddress: ABIEncodable {
    
    public func encode(as type: ABIRawType = .address) throws -> Data {
        guard case .address = type else {
            throw ABIEncoderError.typeMismatch(self, type)
        }
        guard let data = Data(hex: address) else {
            throw ABIEncoderError.wrongAddressFormat(address)
        }
        return data.leftZeroPadding()
    }
    
}

// MARK: Data
extension Data: ABIEncodable {
    
    public func encode(as type: ABIRawType = .dynamicBytes) throws -> Data {
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

// MARK: Array<UInt8>
extension Array<UInt8>: ABIEncodable {
    
    public func encode(as type: ABIRawType = .dynamicBytes) throws -> Data {
        try Data(self).encode()
    }
    
}

// MARK: String
extension String: ABIEncodable {
    
    public func encode(as type: ABIRawType = .string) throws -> Data {
        guard case .string = type else {
            throw ABIEncoderError.typeMismatch(self, type)
        }
        return (try BigUInt(self.count).encode() + self.utf8).rightZeroPadding()
    }
    
}

// MARK: Array
extension Array where Element: ABIEncodable {
    
    public func encode(as type: ABIRawType) throws -> Data {
        switch type {
            case .array(let type, let length):
                guard self.count == length else {
                    throw ABIEncoderError.wrongArrayLength
                }
                return try self.map { try $0.encode(as: type) }.reduce(into: Data(), { $0 += $1 })
            case .dynamicArray(let type):
                return try BigUInt(self.count).encode() + self.map { try $0.encode(as: type) }.reduce(into: Data(), { $0 += $1 })
            default:
                throw ABIEncoderError.typeMismatch(self, type)
        }
    }
}
