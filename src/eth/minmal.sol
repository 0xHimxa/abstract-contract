//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA}  from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED,SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";







contract MinimalAccount is IAccount,Ownable{

error MinimalAccount__NotFromEntryPoint();



    IEntryPoint private immutable i_entrypoint;


modifier requireFromEntryPoint(){
    if(msg.sender != address(i_entrypoint)){
        revert MinimalAccount__NotFromEntryPoint();
    }
    _;
}






constructor(address entrypoint)Ownable(msg.sender){
   i_entrypoint = IEntryPoint(entrypoint); 

}


 function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external requireFromEntryPoint  returns (uint256 validationData){
validationData = _validateSignature(userOp,userOpHash);

// do the validate nounce ur self
//_validateNonce()
_payPrefund(missingAccountFunds);

    }

//  the hash is in EIP-191 version of the signed hash, we will need to convert it to normal
    function _validateSignature(PackedUserOperation calldata userOp,bytes32 userOpHash) internal view returns(uint256 validationData){
bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);
  if(signer != owner()){
//this are numbers but we dont like maggic number so we import them it 0 for faild and 1 for sucess
   return SIG_VALIDATION_FAILED;
  }
  return SIG_VALIDATION_SUCCESS;
    }

// this payback the gas the bundler pay

    function _payPrefund(uint256 missingAccFunds) internal {
if(missingAccFunds != 0){
    (bool success,) = payable(msg.sender).call{value: missingAccFunds, gas: type(uint256).max}("");


}
    }


    function getEntryAddress() external returns(address){
return address(i_entrypoint)}
}