import XCTest
import BigInt
@testable import SmartContract

final class SmartContractTests: XCTestCase {
    
    func testLoadDefault() throws {
        let erc20 = try GenericSmartContract("erc20")
        XCTAssertEqual(erc20.functions.count, 9)
        
        let poolV3 = try GenericSmartContract("lp-pool-v3")
        XCTAssertEqual(poolV3.functions.count, 26)
        
        let poolV2 = try GenericSmartContract("lp-pool-v2")
        XCTAssertEqual(poolV2.functions.count, 27)
        
        let routerV2 = try GenericSmartContract("router-v2")
        XCTAssertEqual(routerV2.functions.count, 24)
        
        let multicall = try GenericSmartContract("multicall")
        XCTAssertEqual(multicall.functions.count, 8)
    }
    
    func testGetFunction() throws {
        let erc20 = GenericSmartContract.ERC20
        
        XCTAssertNoThrow(try erc20.function("decimals"))
        XCTAssertNoThrow(try erc20.function("name"))
        XCTAssertNoThrow(try erc20.function("symbol"))
        
        XCTAssertThrowsError(try erc20.function("fakeFunction")) { error in
            XCTAssertEqual(error as? SmartContractError, SmartContractError.invalidFunctionName("fakeFunction"))
        }
    }
    
    func testFunctionNames() throws {
        let erc20 = GenericSmartContract.ERC20
        let decimalFunction = try erc20.function("decimals")
        XCTAssertEqual(decimalFunction.methodName, "decimals()")
        
        let approveFunction = try erc20.function("approve")
        XCTAssertEqual(approveFunction.methodName, "approve(address,uint256)")
    }
    
    func testFunctionSignatures() throws {
        let erc20 = GenericSmartContract.ERC20
        
        let approveFunction = try erc20.function("approve")
        XCTAssertEqual(try approveFunction.signature(), "0x095ea7b3")
        
        let balanceOf = try erc20.function("balanceOf")
        XCTAssertEqual(try balanceOf.signature(), "0x70a08231")
        
        let transfer = try erc20.function("transfer")
        XCTAssertEqual(try transfer.signature(), "0xa9059cbb")
        
        let allowance = try erc20.function("allowance")
        XCTAssertEqual(try allowance.signature(), "0xdd62ed3e")
    }
    
    func testEncodeFunction() throws {
        let balanceOfAbiData = "0x70a0823100000000000000000000000055d398326f99059ff775485246999027b3197955"
        let erc20 = GenericSmartContract.ERC20
        let balanceOfData = try erc20.function("balanceOf").encode("0x55d398326f99059ff775485246999027b3197955")
        XCTAssertEqual(balanceOfData.hexString, balanceOfAbiData)
        
        let transferAbi = "0xa9059cbb00000000000000000000000055d398326f99059ff775485246999027b3197955000000000000000000000000000000000000000000661efdf2e3b19f7c045f15"
        let transferData = try erc20.function("transfer").encode("0x55d398326f99059ff775485246999027b3197955", BigUInt("123456789123456789123456789"))
        XCTAssertEqual(transferAbi, transferData.hexString)
    }
}

func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}

extension Equatable where Self : Error {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}
