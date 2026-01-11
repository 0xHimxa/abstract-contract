//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {HelperConfig} from "script/helperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;

    function run() public {}

    function generateSignedUserOperation(
        bytes memory callData,
        HelperConfig.NetWorkConfig memory config,
        address _sender
    ) public returns (PackedUserOperation memory) {
        //note sender cant be EOA it have to be the minimal contract address for the user
        uint256 nonce = IEntryPoint(config.entryPoint).getNonce(_sender, 0);
        PackedUserOperation memory userOp = _generateUserOperation(callData, _sender, nonce);

        //sign it and returned
        bytes32 userOpHash = IEntryPoint(config.entryPoint).getUserOpHash(userOp);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANIVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        if (block.chainid == 31337) {
            (v, r, s) = vm.sign(ANIVIL_DEFAULT_KEY, digest);
        } else {
            (v, r, s) = vm.sign(config.account, digest);
        }

        userOp.signature = abi.encodePacked(r, s, v); // Note the order Here

        return userOp;
    }

    function _generateUserOperation(bytes memory callData, address _sender, uint256 nonce)
        internal
        pure
        returns (PackedUserOperation memory)
    {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;

        return PackedUserOperation({
            sender: _sender,
            nonce: nonce,
            initCode: "",
            callData: callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}
