//SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "src/eth/minmal.sol";

contract HelperConfig is Script {
   error HelperConfig__InvalidChainId();

   struct NetWorkConfig{
    address entryPoint;
    address account;
   } 
   uint256 constant sepoliaChainId = 11155111;
   uint256 constant zksyn_sepoliaChainId = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant BURNER_WALLET = 0xA85926f9598AA43A2D8f24246B5e7886C4A5FeEc;
   NetWorkConfig public localNetworkConfig;
 mapping(uint256 chainid=> NetWorkConfig) public networkConfig;


constructor(){
    networkConfig[sepoliaChainId] = getSepoliaConfig();
}


function getConfig() public view returns (NetWorkConfig memory){
    return getConfigByChainId(block.chainid);
}


function getConfigByChainId(uint256 chainId) public view returns (NetWorkConfig memory){

if(chainId == LOCAL_CHAIN_ID){
    return localNetworkConfig;
}
else if(networkConfig[chainId].account == address(0)){
    return networkConfig[chainId];
}
else{
    revert HelperConfig__InvalidChainId();
}



}
    



function getSepoliaConfig() public view returns (NetWorkConfig memory){

 return NetWorkConfig({
            entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
            //usdc: 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0, // Update with your own mock token
            account: BURNER_WALLET
        });
}


function getZksycConfig() public view returns (NetWorkConfig memory){

 return NetWorkConfig({
            entryPoint: address(0),
            //usdc: 0x53844F9577C2334e541Aec7Df7174ECe5dF1fCf0, // Update with your own mock token
            account: BURNER_WALLET
        });
}


function getOrCreateNetWorkConfig() public returns (NetWorkConfig memory){
if(localNetworkConfig.entryPoint== address(0)){
    return localNetworkConfig;
}

//deploy mock
}


}