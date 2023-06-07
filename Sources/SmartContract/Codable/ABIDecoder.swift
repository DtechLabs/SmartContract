//
//  ABIDecoder.swift
//  
//
//  Created by Yuri on 31.05.2023.
//

import Foundation
import BigInt

enum ABIDecoder {
    
    public static func decodeArray<T: ABIDecodable>(arrayOf type: ABIRawType, data: Data, offset: inout UInt) throws -> [T] {
        switch type {
            case .array(_, let length):
                return try decodeFixedArray(arrayOf: type, elementsCount: length, data: data, offset: &offset)
            case .dynamicArray(let innerType):
                let length: BigUInt = try BigUInt.decode(as: .uint256, from: data, offset: &offset)
                if innerType.isFixedSize {
                    return try decodeFixedArray(arrayOf: type, elementsCount: UInt(length), data: data, offset: &offset)
                } else {
                    return try decodeDynamicTypeArray(arrayOf: innerType, elementsCount: UInt(length), data: data, offset: &offset)
                }
            default:
                throw ABIDecoderError.unsupportedType(type)
        }
    }
    
    static func decodeDynamicTypeArray<T: ABIDecodable>(arrayOf type: ABIRawType, elementsCount: UInt, data: Data, offset: inout UInt) throws -> [T] {
        // First we are read head of array
        let headPointer = offset
        guard data.count > headPointer + EVMWordSize * elementsCount else {
            throw ABIDecoderError.missedDataOrCorrupt
        }
        var array: [T] = []
        // Fill head
        let pointers = try (1...elementsCount).map { _ in try BigUInt.decode(as: .uint256, from: data, offset: &offset) }
        // Next read elements
        for pointer in pointers {
            let elementOffset = headPointer + UInt(pointer)
            guard offset == elementOffset else {
                throw ABIDecoderError.missedDataOrCorrupt
            }
            let element = try T.decode(as: type, from: data, offset: &offset)
            array.append(element)
        }
        return array
    }
    
    static func decodeFixedArray<T: ABIDecodable>(arrayOf type: ABIRawType, elementsCount: UInt, data: Data, offset: inout UInt) throws -> [T] {
        guard let innerType = type.innerType else {
            throw ABIDecoderError.unsupportedType(type)
        }
        guard data.count >= offset + innerType.memoryUsage else {
            throw ABIDecoderError.missedDataOrCorrupt
        }
        var array: [T] = []
        for _ in 1...elementsCount {
            let element = try T.decode(as: type, from: data, offset: &offset)
            array.append(element)
        }
        
        return array
    }
    
    public func decodeFixedSizeValue<T: ABIDecodable>(ofType type: ABIRawType, data: Data, offset: inout UInt) throws -> T {
        guard type.isFixedSize else {
            throw ABIDecoderError.shouldBeFixedSize
        }
        let value = try T.decode(as: type, from: data, offset: &offset)
        return value
    }
        
    public static func decode(types: [ABIRawType], data: Data) throws -> [ABIValue] {
        var toReturn = [ABIValue]()
        var consumed: UInt = 0
        for type in types {
            let (value, c) = try decodeSingleType(type: type, data: data, pointer: consumed)
            toReturn.append(ABIValue(value: value, rawType: type))
            consumed = consumed + c
        }
        guard toReturn.count == types.count else {
            throw ABICodableError.parseDataError
        }
        return toReturn
    }
    
    public static func decodeSingleType(type: ABIRawType, data: Data, pointer: UInt = 0) throws -> (value: Any, bytesConsumed: UInt) {
        let (elData, nextPtr) = followTheData(type: type, data: data, pointer: pointer)
        guard let elementItself = elData, let nextElementPointer = nextPtr else {
            throw NSError()
        }
        let startIndex = UInt(elementItself.startIndex)
        switch type {
            case .uint(let bits):
                guard elementItself.count >= 32 else {
                    break
                }
                let mod = BigUInt(1) << bits
                let dataSlice = elementItself[startIndex ..< startIndex + 32]
                let v = BigUInt(dataSlice) % mod
                return (v, type.memoryUsage)
            case .int(let bits):
                guard elementItself.count >= 32 else {break}
                let mod = BigInt(1) << bits
                let dataSlice = elementItself[startIndex ..< startIndex + 32]
                let v = BigInt.fromTwosComplement(data: dataSlice) % mod
                return (v, type.memoryUsage)
            case .address:
                guard elementItself.count >= 32 else {break}
                let dataSlice = elementItself[startIndex + 12 ..< startIndex + 32]
                guard let address = EthereumAddress(dataSlice) else {
                    throw SmartContractError.invalidAddress
                }
                return (address, type.memoryUsage)
            case .bool:
                guard elementItself.count >= 32 else {break}
                let dataSlice = elementItself[startIndex ..< startIndex + 32]
                let v = BigUInt(dataSlice)
                if v == BigUInt(36) ||
                    v == BigUInt(32) ||
                    v == BigUInt(28) ||
                    v == BigUInt(1) {
                    return (true, type.memoryUsage)
                } else if v == BigUInt(35) ||
                            v == BigUInt(31) ||
                            v == BigUInt(27) ||
                            v == BigUInt(0) {
                    return (false, type.memoryUsage)
                }
            case .bytes(let length):
                // ) if dynamic length
                if length == 0 {
                    guard elementItself.count >= 32 else {
                        break
                    }
                    var dataSlice = elementItself[startIndex ..< startIndex + 32]
                    let length = UInt(BigUInt(dataSlice))
                    guard elementItself.count >= 32 + length else {break}
                    dataSlice = elementItself[startIndex + 32 ..< startIndex + 32 + length]
                    return (Data(dataSlice), nextElementPointer)
                } else {
                    guard elementItself.count >= 32 else {
                        break
                    }
                    let dataSlice = elementItself[startIndex ..< startIndex + UInt(length)]
                    return (Data(dataSlice), type.memoryUsage)
                }
            case .string:
                guard elementItself.count >= 32 else {
                    break
                }
                var dataSlice = elementItself[startIndex ..< startIndex + 32 ]
                let length = UInt(BigUInt(dataSlice))
                guard elementItself.count >= 32 + length else {
                    break
                }
                // Zero byte can't be string, so we drop it
                var stringStart = 32
                while (elementItself[stringStart] == 0x0) {
                    stringStart += 1
                }
                dataSlice = elementItself[UInt(stringStart) ..< UInt(stringStart) + length]
                let newlinesAndNulls = CharacterSet.newlines.union(CharacterSet(["\0","\u{04}"]))
                guard let string = String(data: dataSlice, encoding: .utf8)?.trimmingCharacters(in: newlinesAndNulls) else {
                    break
                }
                return (string, nextElementPointer)
            case .array(let subType, let length):
                switch type.arraySize {
                    case .dynamicSize:
                        if subType.isFixedSize {
                            // uint[] like, expect length and elements
                            guard elementItself.count >= 32 else {
                                break
                            }
                            var dataSlice = elementItself[startIndex ..< startIndex + 32]
                            let length = UInt(BigUInt(dataSlice))
                            guard elementItself.count >= 32 + subType.memoryUsage*length else {break}
                            dataSlice = elementItself[startIndex + 32 ..< startIndex + 32 + subType.memoryUsage*length]
                            var subpointer: UInt = 32
                            var toReturn = [Any]()
                            for _ in 0 ..< length {
                                let (valueUnwrapped, consumedUnwrapped) = try decodeSingleType(type: subType, data: elementItself, pointer: subpointer)
                                toReturn.append(valueUnwrapped)
                                subpointer = subpointer + consumedUnwrapped
                            }
                            return (toReturn, type.memoryUsage)
                        } else {
                            // in principle is true for tuple[], so will work for string[] too
                            guard elementItself.count >= 32 else {break}
                            var dataSlice = elementItself[startIndex ..< startIndex + 32]
                            let length = UInt(BigUInt(dataSlice))
                            guard elementItself.count >= 32 else {break}
                            dataSlice = Data(elementItself[startIndex + 32 ..< UInt(elementItself.count)])
                            var subpointer: UInt = 0
                            var toReturn = [Any]()
                            for _ in 0 ..< length {
                                let (valueUnwrapped, consumedUnwrapped) = try decodeSingleType(type: subType, data: dataSlice, pointer: subpointer)
                                toReturn.append(valueUnwrapped)
                                if subType.isFixedSize {
                                    subpointer = subpointer + consumedUnwrapped
                                } else {
                                    subpointer = consumedUnwrapped // need to go by nextElementPointer
                                }
                            }
                            return (toReturn, nextElementPointer)
                        }
                    case .staticSize(let staticLength):
                        guard length == staticLength else {
                            break
                        }
                        var toReturn = [Any]()
                        var consumed: UInt = 0
                        for _ in 0 ..< length {
                            let (valueUnwrapped, consumedUnwrapped) = try decodeSingleType(type: subType, data: elementItself, pointer: consumed)
                            toReturn.append(valueUnwrapped)
                            consumed = consumed + consumedUnwrapped
                        }
                        if subType.isFixedSize {
                            return (toReturn, consumed)
                        } else {
                            return (toReturn, nextElementPointer)
                        }
                    case .notArray:
                        break
                }
//            case .tuple(types: let subTypes):
//                var toReturn = [Any]()
//                var consumed: UInt64 = 0
//                for i in 0 ..< subTypes.count {
//                    let (v, c) = decodeSingleType(type: subTypes[i], data: elementItself, pointer: consumed)
//                    guard let valueUnwrapped = v, let consumedUnwrapped = c else {return (nil, nil)}
//                    toReturn.append(valueUnwrapped)
//                    // When decoding a tuple that is not static or an array with a subtype that is not static,
//                    // the second value in the tuple returned by decodeSignleType is a pointer to the next element,
//                    // NOT the length of the consumed element. So when decoding such an element, consumed should
//                    // be set to consumedUnwrapped, NOT incremented by consumedUnwrapped.
//                    switch subTypes[i] {
//                        case .array(type: let subType, length: _):
//                            if !subType.isStatic {
//                                consumed = consumedUnwrapped
//                            } else {
//                                consumed = consumed + consumedUnwrapped
//                            }
//                        case .tuple(types: _):
//                            if !subTypes[i].isStatic {
//                                consumed = consumedUnwrapped
//                            } else {
//                                consumed = consumed + consumedUnwrapped
//                            }
//                        default:
//                            consumed = consumed + consumedUnwrapped
//                    }
//                }
//                if type.isStatic {
//                    return (toReturn, consumed)
//                } else {
//                    return (toReturn, nextElementPointer)
//                }
                //        case .function:
                //            guard elementItself.count >= 32 else {break}
                //            let dataSlice = elementItself[startIndex + 8 ..< startIndex + 32]
                //            return (Data(dataSlice), type.memoryUsage)
                //        }
            default:
                break
        }
        throw ABICodableError.unrecognizedCase
    }
    
    private static func followTheData(type: ABIRawType, data: Data, pointer: UInt = 0) -> (elementEncoding: Data?, nextElementPointer: UInt?) {
        if type.isFixedSize {
            guard data.count >= pointer + type.memoryUsage else {
                return (nil, nil)
            }
            let elementItself = data[data.startIndex + Int(pointer) ..< data.startIndex + Int(pointer + type.memoryUsage)]
            let nextElement = pointer + type.memoryUsage
            return (Data(elementItself), nextElement)
        } else {
            guard data.count >= pointer + type.memoryUsage else {
                return (nil, nil)
            }
            let dataSlice = data[data.startIndex + Int(pointer) ..< data.startIndex + Int(pointer + type.memoryUsage)]
            let bn = UInt(BigUInt(dataSlice).description)!
            if case .string = type {
                let nextElement = pointer + UInt(data.count)
                return (data, nextElement)
            } else if case .array(_, let length) = type, length == 0 { // If dynamic array
                let nextElement = pointer + UInt(data.count)
                return (data, nextElement)
            } else if case .array(_, let length) = type, length > 0  {
                return (Data(data), UInt(data.count))
            } else {
                let elementPointer = UInt(bn)
                let startIndex = UInt(data.startIndex)
                let elementItself = data[startIndex + elementPointer ..< startIndex + UInt(data.count)]
                let nextElement = pointer + type.memoryUsage
                return (Data(elementItself), nextElement)
            }
        }
    }

}
