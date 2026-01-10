//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "src/eth/minmal.sol";
import {HelperConfig} from "script/helperConfig.s.sol";
import {DeployMinimal} from "script/deployMinimal.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp} from "script/sendUserOp.s.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccountTest is Test {
    using MessageHashUtils for bytes32;

    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    ERC20Mock usdc;
    uint256 constant AMOUNT = 1e18;
    address randomUser = makeAddr("randomUser");
    SendPackedUserOp sendPakedUserOp;

    function setUp() public {
        DeployMinimal deployMinimal = new DeployMinimal();

        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
        usdc = new ERC20Mock();
        sendPakedUserOp = new SendPackedUserOp();
    }

    //uscc mint
    //approve some amount
    //usdc contract
    //come from the entry points

    function testOwnerCanExecuteCommands() public {
        //arrage
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address des = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        //act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(des, value, functionData);
        //assert

        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function testNotOwnerCanNotExecuteCommands() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address des = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        //act
        vm.prank(randomUser);

        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(des, value, functionData);
        //assert
    }

    function testReoverSignOp() public {
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address des = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory exuteCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, des, value, functionData);

        PackedUserOperation memory packedUserOp =
            sendPakedUserOp.generateSignedUserOperation(exuteCallData, helperConfig.getConfig());

        bytes32 userOpHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        address signer = ECDSA.recover(userOpHash.toEthSignedMessageHash(), packedUserOp.signature);
       
        assertEq(signer, minimalAccount.owner());
    }


//1. Sign user ops
//2.Call validate userops
//3. Assert the return is correct;

function testValidateOfUserOps() public{
         assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address des = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        bytes memory exuteCallData = abi.encodeWithSelector(MinimalAccount.execute.selector, des, value, functionData);

        PackedUserOperation memory packedUserOp =
            sendPakedUserOp.generateSignedUserOperation(exuteCallData, helperConfig.getConfig());

        bytes32 userOpHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
uint256 missingAccountFunds = 1e18;


//act
vm.prank(helperConfig.getConfig().entryPoint);
uint256 validationData = minimalAccount.validateUserOp(packedUserOp, userOpHash, missingAccountFunds);
//assert
 assertEq(validationData, 0);

}


 
 f





}
