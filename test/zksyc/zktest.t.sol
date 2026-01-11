//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "src/zky/zkminimal.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {
    Transaction,
    MemoryTransactionHelper
} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";

contract ZkMinimalAccountTest is Test {
    ZkMinimalAccount zkminimal;
    ERC20Mock usdc;
    uint256 constant AMOUNT = 1e18;
bytes32 constant EMPTY_BYTES32 = bytes32(0);

    function setUp() public {
        zkminimal = new ZkMinimalAccount();
        usdc = new ERC20Mock();
    }

    function testZkOwnerCanExecuteCommand() public {
        //arrage

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(zkminimal), AMOUNT);


Transaction memory transaction = _createUnsignedTransaction(zkminimal.owner(),113,dest,value,functionData);



        //assert
        vm.prank(zkminimal.owner());
        zkminimal.executeTransaction(EMPTY_BYTES32,EMPTY_BYTES32,transaction);

        //act
        assertEq(usdc.balanceOf(address(zkminimal)), AMOUNT);
    }

    function _createUnsignedTransaction(
        address from,
        uint8 transactionType,
        address to,
        uint256 value,
        bytes memory data
    ) internal returns (Transaction memory){
uint256 nonce = vm.getNonce(address(zkminimal));
bytes32[] memory factoryDeps = new bytes32[](0);

return Transaction({
    txType: transactionType,
    from: uint256(uint160(from)),
    to: uint256(uint160(to)),
    gasLimit: 16777216,
    gasPerPubdataByteLimit: 16777216,
    maxFeePerGas: 16777216,
    maxPriorityFeePerGas: 16777216,
    paymaster: 0,
    nonce: nonce,
    
    value: value,
    reserved: [uint256(0), uint256(0), uint256(0), uint256(0)],
    data: data,
    signature:hex"",
    factoryDeps: factoryDeps,
    paymasterInput: hex"",
    reservedDynamic: hex""
});

    }
}
