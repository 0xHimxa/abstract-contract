//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ZkMinimalAccount} from "src/zky/zkminimal.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {
    Transaction,
    MemoryTransactionHelper
} from "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {
   
    BOOTLOADER_FORMAL_ADDRESS
   
} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";

import {
  
    ACCOUNT_VALIDATION_SUCCESS_MAGIC
} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";

  

contract ZkMinimalAccountTest is Test {
using MessageHashUtils for bytes32;

    ZkMinimalAccount zkminimal;
    ERC20Mock usdc;
    uint256 constant AMOUNT = 1e18;
bytes32 constant EMPTY_BYTES32 = bytes32(0);
    address constant ANVIL_DEFAULT_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;


    function setUp() public {
        zkminimal = new ZkMinimalAccount();
        zkminimal.transferOwnership(ANVIL_DEFAULT_ACCOUNT);
        usdc = new ERC20Mock();
        vm.deal(address(zkminimal), 6e18);
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




function testzkValidateTx()public{

        address dest = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(zkminimal), AMOUNT);

Transaction memory transaction = _createUnsignedTransaction(zkminimal.owner(),113,dest,value,functionData);
transaction = _signTransaction(transaction);

vm.prank( BOOTLOADER_FORMAL_ADDRESS);
bytes4 magic = zkminimal.validateTransaction(EMPTY_BYTES32,EMPTY_BYTES32,transaction);


assertEq(magic,ACCOUNT_VALIDATION_SUCCESS_MAGIC);


}










function _signTransaction(Transaction memory _transaction) internal returns (Transaction memory){
bytes32 unsignedtx = MemoryTransactionHelper.encodeHash(_transaction);
//bytes32 digest = unsignedtx.toEthSignedMessageHash();
        
        
         uint8 v;
        bytes32 r;
        bytes32 s;
       
        uint256 ANIVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
            (v, r, s) = vm.sign(ANIVIL_DEFAULT_KEY,unsignedtx);

           Transaction memory signedTransaction = _transaction;
            // Note the order Here
        
           signedTransaction.signature = abi.encodePacked(r, s, v);

return signedTransaction;

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
