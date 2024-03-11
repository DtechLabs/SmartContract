# SmartContract

> **NOTE** The library may contain some artefact code that will be cleared in the near future.

This library simplifies the process of interacting with any Ethereum Virtual Machine (EVM) smart contract from a Swift iOS app. Inspired by JavaScript implementations, it enables users to call smart contract methods by name and pass parameters effortlessly.

The library takes advantage of Swift's latest `async`/`await` functionality and supports `dynamic callable` and `dynamic members lookup`.

**Example usage:**
```swift
let contract = GenericSmartContract(...)
...
let balance = try await contract("balanceOf", address).value as BigUInt
...
let result =  try await contract("transfer", address, amount).value as! Bool
```

### How to add library

- **Swift Package Manager**: Add this to the dependency section of your Package.swift manifest:

```swift
.package(url: "https://github.com/DtechLabs/SmartContract.git", from: "1.0.0")
```

### Create SmartContract

To begin working with a smart contract, simply load its ABI:

```swift
let abi: String = .... // String with ABI Json data
let contract1 = try GenericSmartContract(abiJson: abi) 

// or
let abiData: Data = ... // Data with UTF8 string of ABI 
let contract2 = try GenericSmartContract(abi: abiData) 
```

The framework includes some preloaded ABIs, formed from my last project, which will be expanded in future versions. You can suggest additional ABIs to include in the [List of Smart Contracts which ABIs should be preloaded](https://github.com/DtechLabs/SmartContract/issues/1)


The framework has some preloaded ABI. List formed from my last project and will be expanded in the next versions. you can propose what should be there in 
- ERC20 ("erc20")
- Multicall ("multicall")
- ...

Thus, loading them is straightforward:
```swift
let erc20 = GenericSmartContract.ERC20
```


### How to call function of the SmartContract

To invoke a function on a SmartContract, you need an RPC node interactor. You can use any existing libraries for this purpose or create your own. Implement the RPCApi protocol, which calls the `eth_call` function.

The framework provides a simple implementation of this protocol - `GenericRpcNode`, mainly for testing purposes.

Combine it with `GenericSmartContract` along with the contract address:
```swift
let rpc = GenericRpcNode(URL(string: "https://rpc.payload.de")!)
let erc20 = try GenericSmartContract("erc20", rpc: rpc, address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
        
let result = try await erc20("name")
print("Name is", result.value)
```

Or for alternative usage:
```swift
let erc20 = GenericSmartContract.ERC20
let abiData = erc20.name()

// And then somewhere in the code put abiData into RPC eth_call request 
```


### Multicall contract

Using the Multicall SmartContract is slightly more complex. An independent structure `MulticallContract` is designed for it. After initialization, you can add `MulticallContract.Call` as desired. Remember, the size of abiData is limited to no more than 500 calls, depending on the functions you invoke. It's advisable not to exceed 200 calls.
```swift
let multicall = MulticallContract(rpc: rpc, address: address)
let calls: [MulticallContract.Call] = [
    .init(address: wrappedETH, bytes: try erc20.contract.abi("name")),
    .init(address: wrappedETH, bytes: try erc20.contract.abi("symbol"))
]

// For abiData
let abiData = try multicall.aggregateAbi(calls)

// OR if you call it directly
var calls = [
    try MulticallContract.call(erc20.contract.function("name"), address: wrappedETH.address),
    try MulticallContract.call(erc20.contract.function("symbol"), address: wrappedETH.address)
]
        
try await multicall.aggregate(&calls)
let name: String = try calls[0].getResult("")
let symbol: String = try calls[1].getResult(by: 0)
```

Results of each function are stored in the same Call, retrievable via the `getResult` function by **name** or **index**. The `aggregate` function also returns an array with raw data.

!!! Remember, if even one call fails, all calls return empty.


### Returning values 

SmartContract functions return a `SmartContractResult`.
SmartContractResult utilizes ***dynamicMemberLookup***, allowing you to access the resulting parameter by its name from the ABI:
```swift
let result = try await quadratRouter.getMintAmounts(
    hyperpool: strategy, 
    paymentToken: token, 
    paymentAmount: amount
    )

let amount0: BigUInt = result.amount0!
let amount1: BigUInt = result.amount1!
let token0: EthereumAddress = result.token0!
let token1: EthereumAddress = result.token1!
```

If a function returns only one value often without a name, it can be accessed as `value`:
```swift
let symbol = try await erc20("symbol").value as! String
```

### Returning and Accepting types

SmartContractFunction accepts and returns values conforming to `ABIEncodable` and `ABIDecodable` protocols, respectively.

Supported `ABICodable` types include:

- BigUInt 
- BigInt
- Bool
- Data
- EthreumAddress
- String
- Array<UInt8>
- Array<ABIEncodable>

### How to Retrieve the ABI of a SmartContract from an Address

To obtain the ABI(Application Binary Interface) from a SmartContract Address, use a **Chain Explorer** that supports **EIP3091**. Input the explorer's URL during initialization:
```swift
let abiLoader = SmartContractAbiLoader(explorerUrl: "https://etherscan.io")
```

Alternatively, a helper function preloads information about EVM chains from the [ChainId Network](https://chainid.network):
```swift
let _ = ChainsDataStorage()
// Ensure that there's at least one Ethereum chain explorer available
let chainData = ChainsDataStorage.chains.first { $0.chainId == 1 }!
let explorer = chainData.explorers!.first { $0.standard == .EIP3091 }!
        
let loader = try SmartContractAbiLoader(explorer)
let abi = try await loader.loadAbi(address: "0x...")

let contract = try GenericSmartContract(abiJson: abi)
```

For more samples how to works with the library you can find in the `Tests`.
