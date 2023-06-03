//
//  ABIEncoder.swift
//  
//
//  Created by Yuri on 31.05.2023.
//
import Foundation
import BigInt

//public enum ABIEncoder {
//    
//    static func encode() throws {
//        
//    }
//    
//    /// Performs ABI encoding conforming to [the documentation of encoding](https://docs.soliditylang.org/en/develop/abi-spec.html#basic-design) in Solidity.
//    ///
//    /// **It does not add the data offset for dynamic types!!** To return single value **with data offset** use the following instead:
//    /// ```swift
//    /// ABIEncoder.encode(types: [type], values: [value])
//    /// ```
//    /// Almost identical to use of `web3.eth.abi.encodeParameter` in web3.js.
//    /// Calling `web3.eth.abi.encodeParameter('string','test')` in web3.js will return the following:
//    /// ```
//    /// 0x0000000000000000000000000000000000000000000000000000000000000020
//    /// 0000000000000000000000000000000000000000000000000000000000000004
//    /// 7465737400000000000000000000000000000000000000000000000000000000
//    /// ```
//    /// but calling `ABIEncoder.encodeSingleType(type: .string, value: "test")` will return:
//    /// ```
//    /// 0x0000000000000000000000000000000000000000000000000000000000000004
//    /// 7465737400000000000000000000000000000000000000000000000000000000
//    /// ```
//    /// - Parameters:
//    ///   - type: Solidity type of the `value`;
//    ///   - value: value to encode.
//    /// - Returns: ABI encoded data, e.g. function call parameters. Returns `nil` if:
//    ///     - `types.count != values.count`;
//    ///     - encoding has failed (e.g. type mismatch).
//    public static func encodeSingleType(type: ABIRawType, value: Any) throws -> Data {
//        switch type {
//        case .uint(let bits):
//            let biguint = convertToBigUInt(value)
//            return biguint == nil ? nil : biguint!.abiEncode(bits: 256)
//        case .int:
//            let bigint = convertToBigInt(value)
//            return bigint == nil ? nil : bigint!.abiEncode(bits: 256)
//        case .address:
//            if let string = value as? String {
//                guard let address = EthereumAddress(string) else { return nil }
//                let data = address.addressData
//                return data.setLengthLeft(32)
//            } else if let address = value as? EthereumAddress {
//                guard address.isValid else {break}
//                let data = address.addressData
//                return data.setLengthLeft(32)
//            } else if let data = value as? Data {
//                return data.setLengthLeft(32)
//            }
//        case .bool:
//            if let bool = value as? Bool {
//                if bool {
//                    return BigUInt(1).abiEncode(bits: 256)
//                } else {
//                    return BigUInt(0).abiEncode(bits: 256)
//                }
//            }
//        case .bytes(let length):
//            guard let data = convertToData(value) else {break}
//            if data.count > length {break}
//            return data.setLengthRight(32)
//        case .string:
//            if let string = value as? String {
//                var dataGuess: Data?
//                if string.hasHexPrefix() {
//                    dataGuess = Data.fromHex(string.lowercased().stripHexPrefix())
//                } else {
//                    dataGuess = string.data(using: .utf8)
//                }
//                guard let data = dataGuess else {break}
//                let minLength = ((data.count + 31) / 32)*32
//                guard let paddedData = data.setLengthRight(UInt64(minLength)) else {break}
//                let length = BigUInt(data.count)
//                guard let head = length.abiEncode(bits: 256) else {break}
//                let total = head+paddedData
//                return total
//            }
//        case .dynamicBytes:
//            guard let data = convertToData(value) else {break}
//            let minLength = ((data.count + 31) / 32)*32
//            guard let paddedData = data.setLengthRight(UInt64(minLength)) else {break}
//            let length = BigUInt(data.count)
//            guard let head = length.abiEncode(bits: 256) else {break}
//            let total = head+paddedData
//            return total
//        case .array(type: let subType, length: let length):
//            switch type.arraySize {
//            case .dynamicSize:
//                guard length == 0 else {break}
//                guard let val = value as? [Any] else {break}
//                guard let lengthEncoding = BigUInt(val.count).abiEncode(bits: 256) else {break}
//                if subType.isStatic {
//                    // work in a previous context
//                    var toReturn = Data()
//                    for i in 0 ..< val.count {
//                        let enc = encodeSingleType(type: subType, value: val[i])
//                        guard let encoding = enc else {break}
//                        toReturn.append(encoding)
//                    }
//                    let total = lengthEncoding + toReturn
//                    return total
//                } else {
//                    // create new context
//                    var tails = [Data]()
//                    var heads = [Data]()
//                    for i in 0 ..< val.count {
//                        let enc = encodeSingleType(type: subType, value: val[i])
//                        guard let encoding = enc else { return nil }
//                        heads.append(Data(repeating: 0x0, count: 32))
//                        tails.append(encoding)
//                    }
//                    var headsConcatenated = Data()
//                    for h in heads {
//                        headsConcatenated.append(h)
//                    }
//                    var tailsPointer = BigUInt(headsConcatenated.count)
//                    headsConcatenated = Data()
//                    var tailsConcatenated = Data()
//                    for i in 0 ..< val.count {
//                        let head = heads[i]
//                        let tail = tails[i]
//                        if tail != Data() {
//                            guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
//                            headsConcatenated.append(newHead)
//                            tailsConcatenated.append(tail)
//                            tailsPointer = tailsPointer + BigUInt(tail.count)
//                        } else {
//                            headsConcatenated.append(head)
//                            tailsConcatenated.append(tail)
//                        }
//                    }
//                    let total =  lengthEncoding + headsConcatenated + tailsConcatenated
//                    return total
//                }
//            case .staticSize(let staticLength):
//                guard staticLength != 0 else {break}
//                guard let val = value as? [Any] else {break}
//                guard staticLength == val.count else {break}
//                if subType.isStatic {
//                    // work in a previous context
//                    var toReturn = Data()
//                    for i in 0 ..< val.count {
//                        let enc = encodeSingleType(type: subType, value: val[i])
//                        guard let encoding = enc else {break}
//                        toReturn.append(encoding)
//                    }
//                    let total = toReturn
//                    return total
//                } else {
//                    // create new context
//                    var tails = [Data]()
//                    var heads = [Data]()
//                    for i in 0 ..< val.count {
//                        let enc = encodeSingleType(type: subType, value: val[i])
//                        guard let encoding = enc else { return nil }
//                        heads.append(Data(repeating: 0x0, count: 32))
//                        tails.append(encoding)
//                    }
//                    var headsConcatenated = Data()
//                    for h in heads {
//                        headsConcatenated.append(h)
//                    }
//                    var tailsPointer = BigUInt(headsConcatenated.count)
//                    headsConcatenated = Data()
//                    var tailsConcatenated = Data()
//                    for i in 0 ..< val.count {
//                        let tail = tails[i]
//                        guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
//                        headsConcatenated.append(newHead)
//                        tailsConcatenated.append(tail)
//                        tailsPointer = tailsPointer + BigUInt(tail.count)
//                    }
//                    let total = headsConcatenated + tailsConcatenated
//                    return total
//                }
//            case .notArray:
//                break
//            }
//        case .tuple(types: let subTypes):
//            var tails = [Data]()
//            var heads = [Data]()
//            guard let val = value as? [Any] else {break}
//            for i in 0 ..< subTypes.count {
//                let enc = encodeSingleType(type: subTypes[i], value: val[i])
//                guard let encoding = enc else { return nil }
//                if subTypes[i].isStatic {
//                    heads.append(encoding)
//                    tails.append(Data())
//                } else {
//                    heads.append(Data(repeating: 0x0, count: 32))
//                    tails.append(encoding)
//                }
//            }
//            var headsConcatenated = Data()
//            for h in heads {
//                headsConcatenated.append(h)
//            }
//            var tailsPointer = BigUInt(headsConcatenated.count)
//            headsConcatenated = Data()
//            var tailsConcatenated = Data()
//            for i in 0 ..< subTypes.count {
//                let head = heads[i]
//                let tail = tails[i]
//                if !subTypes[i].isStatic {
//                    guard let newHead = tailsPointer.abiEncode(bits: 256) else { return nil }
//                    headsConcatenated.append(newHead)
//                    tailsConcatenated.append(tail)
//                    tailsPointer = tailsPointer + BigUInt(tail.count)
//                } else {
//                    headsConcatenated.append(head)
//                    tailsConcatenated.append(tail)
//                }
//            }
//            let total = headsConcatenated + tailsConcatenated
//            return total
//        case .function:
//            if let data = value as? Data {
//                return data.setLengthLeft(32)
//            }
//        }
//        return nil
//    }
//}
