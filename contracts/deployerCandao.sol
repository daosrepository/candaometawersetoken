// SPDX-License-Identifier: MIT all rights to sergiey
pragma solidity 0.8.1;

import "./CandaoTokenForDeploy.sol";

contract deployer{
bool public everUsed = false;
CandaoToken public OurToken;
address public ourTokenA = address(0x0);
address payable ourTeamWalletA = payable(address(0x1357A9f5EC664fB4d22CAa1660442e2Afb01103a));
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
OurToken.addTeamDaoMember(address(0x1357A9f5EC664fB4d22CAa1660442e2Afb01103a));

//Private key: 3491aa2270b51cd9f51048cacc2b8086c33f571e98a322194c30169d00ad12b7

OurToken.addTeamDaoMember(address(0x1));
OurToken.addTeamDaoMember(address(0x2));
OurToken.addTeamDaoMember(address(0x3));
OurToken.addTeamDaoMember(address(0x4));
OurToken.addTeamDaoMember(address(0x5));
OurToken.addTeamDaoMember(address(0x6));
OurToken.addTeamDaoMember(address(0x7));
OurToken.addTeamDaoMember(address(0x8));
OurToken.sealDaoNow();

return ourTokenA;
}



}
