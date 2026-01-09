//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "src/eth/minmal.sol";
import {HelperConfig} from "script/helperConfig.s.sol";
import {DeployMinimal} from "script/deployMinimal.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract MinimalAccountTest is Test{
HelperConfig helperConfig;
MinimalAccount minimalAccount;
ERC20Mock usdc;
uint256 constant AMOUNT = 1e18;
address randomUser = makeAddr("randomUser");

function setUp() public{
DeployMinimal deployMinimal = new DeployMinimal();

( helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
usdc = new ERC20Mock();
}


//uscc mint
//approve some amount
//usdc contract
//come from the entry points


function testOwnerCanExecuteCommands()public{
    //arrage
    assertEq(usdc.balanceOf(address(minimalAccount)),0);
    address des = address(usdc);
    uint256 value=0;
    bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);

    //act
    vm.prank(minimalAccount.owner());
    minimalAccount.execute(des,value,functionData);
    //assert

    assertEq(usdc.balanceOf(address(minimalAccount)),AMOUNT);




}


function testNotOwnerCanNotExecuteCommands()public{
       assertEq(usdc.balanceOf(address(minimalAccount)),0);
    address des = address(usdc);
    uint256 value=0;
    bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector,address(minimalAccount),AMOUNT);

    //act
   vm.prank(randomUser);
   
   vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector );
    minimalAccount.execute(des,value,functionData);
    //assert



}



}