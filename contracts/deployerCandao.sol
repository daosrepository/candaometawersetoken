// SPDX-License-Identifier: MIT all rights to sergiey
pragma solidity 0.8.1;

import "./CandaoTokenForDeploy.sol";

contract deployer{
bool public everUsed = false;
CandaoToken public OurToken;
address public ourTokenA = address(0x0);
address payable ourTeamWalletA = payable(address(0x15973A179D3233aA406F7955BE5667Fd8654b726));
constructor() {
}

function deployOnce() public payable returns(address){
if(everUsed){revert();}
OurToken = new CandaoToken("CANDAOTOKEN","CDNT",ourTeamWalletA);
ourTokenA=payable(address(OurToken));
everUsed=true;
return ourTokenA;
}

function configDeploy() public returns(address){
//configuration of CANDAOToken
OurToken.addTeamDaoMember(address(0xc278E7c241E69ceaA342A5Bb51fd96a094DAE303));
OurToken.addTeamDaoMember(address(0x83eFAC540508fc7E828e892E43d6C729E90E9D52));
OurToken.addTeamDaoMember(address(0xDcdCd562A96cBC8DF0411560b5344153E0D113E8));
OurToken.addTeamDaoMember(address(0x63f0d3F78b5dd68Ca3109EaFb590b60A34FaA3b5));
OurToken.addTeamDaoMember(address(0x352d62F8F153C451C21dde2bB2E7f1792d7d3e3D));
OurToken.addTeamDaoMember(address(0xb1ac6178AC4510a24868EFB08697cb7A9818425C));
OurToken.addTeamDaoMember(address(0x55CeF60A19DfC48ed8519819590DE68abB806D28));
OurToken.addTeamDaoMember(address(0xf6a87b9E684D5Ed3040D46Af3A47e3Ab59d8DB61));
OurToken.addTeamDaoMember(address(0x5d9150d0ce8e6232C450Cad8A1F66f0818dE9a7E));
OurToken.sealDaoNow();

return ourTokenA;
}



}
