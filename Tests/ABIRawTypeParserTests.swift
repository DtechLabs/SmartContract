//
//  ABIRawTypeParserTests.swift
//  
//
//  Created by Yuri on 31.05.2023.
//

import XCTest
@testable import SmartContract

final class ABIRawTypeParserTests: XCTestCase {

    func testSimpleTypes() throws {
        XCTAssertEqual(try ABIRawTypeParser.parse("int16"), .int(bits: 16))
        XCTAssertEqual(try ABIRawTypeParser.parse("uint256"), .uint(bits: 256))
        XCTAssertEqual(try ABIRawTypeParser.parse("address"), .address)
        XCTAssertEqual(try ABIRawTypeParser.parse("bool"), .bool)
        XCTAssertEqual(try ABIRawTypeParser.parse("tuple[]"), .tuple)
        XCTAssertEqual(try ABIRawTypeParser.parse("uint256[]"), .array(type: .uint(bits: 256)))
        XCTAssertEqual(try ABIRawTypeParser.parse("address[]"), .array(type: .address))
        XCTAssertEqual(try ABIRawTypeParser.parse("address[4]"), .array(type: .address, length: 4))
        XCTAssertEqual(try ABIRawTypeParser.parse("uint160[2]"), .array(type: .uint(bits: 160), length: 2))
    }

}
