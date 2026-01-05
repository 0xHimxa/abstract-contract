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


function setUp() public{
DeployMinimal deployMinimal = new DeployMinimal();

( helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();

}





}