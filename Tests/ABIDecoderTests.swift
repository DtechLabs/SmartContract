//
//  ABIDecoderTests.swift
//  
//
//  Created by Yuri on 01.06.2023.
//
import XCTest
import BigInt
@testable import SmartContract

final class ABIDecoderTests: XCTestCase {

    func testValueDecoderUInt256() throws {
        let expected: BigUInt = "1234567890987654321"
        let inputs = [
            "000000000000000000000000000000000000000000000000112210f4b16c1cb1",
            "000000000000000000000000000000000000000000000000112210f4b16c1cb10000000000000000000000000000000000000000000000000000000000000000"
        ]
        
        for input in inputs {
            let data = Data(hex: input)!
            XCTAssertEqual(expected, try ABIDecoder.decodeSingleType(type: .uint256, data: data).value as? BigUInt, input)
            XCTAssertEqual(32, try ABIDecoder.decodeSingleType(type: .uint(bits: 256), data: data).bytesConsumed, input)
        }
    }

    func testValueDecoderValue() throws {
        var offset: UInt = 0
        let data42 = Data(hex: "000000000000000000000000000000000000000000000000000000000000002a")!
        XCTAssertEqual(BigUInt(42), try BigUInt.decode(as: .uint256, from: data42, offset: &offset))
        XCTAssertEqual(offset, EVMWordSize)
        offset = 0
        let data24 = Data(hex: "0000000000000000000000000000000000000000000000000000000000000018")!
        XCTAssertEqual(BigUInt(24), try BigUInt.decode(as: .uint8, from: data24, offset: &offset))
        XCTAssertEqual(offset, EVMWordSize)
        offset = 0
        let addressData = Data(hex: "000000000000000000000000f784682c82526e245f50975190ef0fff4e4fc077")!
        XCTAssertEqual(EthereumAddress("0xf784682c82526e245f50975190ef0fff4e4fc077"), try EthereumAddress.decode(from: addressData, offset: &offset))
        XCTAssertEqual(offset, EVMWordSize)
        let stringData = Data(hex: "000000000000000000000000000000000000000000000000000000000000002c48656c6c6f20576f726c64212020202048656c6c6f20576f726c64212020202048656c6c6f20576f726c64210000000000000000000000000000000000000000")!
        offset = 0
        let decodedString = try String.decode(from: stringData, offset: &offset)
        XCTAssertEqual("Hello World!    Hello World!    Hello World!", decodedString)
        XCTAssertEqual(UInt(stringData.count), offset)
        
        offset = 0
        let bytesData = Data(hex: "3132333435363738393000000000000000000000000000000000000000000000")!
        let original = try Data.decode(as: .bytes(count: 10), from: bytesData, offset: &offset)
        XCTAssertEqual("0x31323334353637383930", original.hexString)
        XCTAssertEqual(offset, UInt(bytesData.count))
    }
    
    func testValueDecoderArrayUInt8() throws {
        let input = Data(hex: "000000000000000000000000000000000000000000000000000000000000003100000000000000000000000000000000000000000000000000000000000000320000000000000000000000000000000000000000000000000000000000000033")!
        var offset: UInt = 0
        let array: [BigUInt] = try ABIDecoder.decodeArray(arrayOf: .array(type: .uint8, length: 3), data: input, offset: &offset)
        XCTAssertEqual([49,50,51], array)
        XCTAssertEqual(offset, UInt(input.count))
    }

    func testValueDecoderArrayAddress() throws {
        let input = Data(hex: "0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000f784682c82526e245f50975190ef0fff4e4fc0770000000000000000000000002e00cd222cb42b616d86d037cc494e8ab7f5c9a3")!
        var offset: UInt = 0
        let array: [EthereumAddress] = try ABIDecoder.decodeArray(arrayOf: .dynamicArray(ofType: .address), data: input, offset: &offset)
        let sample = [
            EthereumAddress("0xf784682c82526e245f50975190ef0fff4e4fc077")!,
            EthereumAddress("0x2e00cd222cb42b616d86d037cc494e8ab7f5c9a3")!,
        ]
        XCTAssertEqual(sample, array)
        XCTAssertEqual(offset, UInt(input.count))
    }
    
    func testValueDecoderArrayBytes() throws {
        let input = Data(hex: "0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000002101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031022220000000000000000000000000000000000000000000000000000000000")!
        let sample = [Data(hex: "0x1011")!, Data(hex: "0x102222")!]
        var offset: UInt = 0
        let array: [Data] = try ABIDecoder.decodeArray(arrayOf: .dynamicArray(ofType: .dynamicBytes), data: input, offset: &offset)
        XCTAssertEqual(sample, array)
        XCTAssertEqual(offset, UInt(input.count))
    }

}
