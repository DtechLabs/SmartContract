// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmartContract",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SmartContract",
            targets: ["SmartContract"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: Version(5, 0, 0)),
        // This library dependency from WalletConnectSwift v2
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.5.1")),
        .package(url: "https://github.com/Flight-School/AnyCodable",.upToNextMajor(from: "0.6.5"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SmartContract",
            dependencies: ["BigInt", "CryptoSwift"],
            resources: [
                .process("ABI/erc20.json"),
                .process("ABI/lp-pool-v2.json"),
                .process("ABI/lp-pool-v3.json"),
                .process("ABI/router-v2.json"),
                .process("ABI/multicall.json")
            ]
        ),
        .testTarget(
            name: "SmartContractTests",
            dependencies: ["SmartContract", "BigInt", "AnyCodable"],
            path: "Tests"
        )
    ]
)
