// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./RecoverableFunds.sol";
import "./interfaces/ICallbackContract.sol";
import "./WithCallback.sol";
//import "@openzeppelin/constracts/token/ERC20/utils/SafeERC20.sol";
/**
 * @dev CandaoToken
 */
//contract CandaoToken is ERC20, ERC20Burnable, Pausable, RecoverableFunds, WithCallback {
contract CandaoToken is ERC20, ERC20Burnable, Pausable, RecoverableFunds {


    address[] public daoMembers;
    uint256 pauseNow=0;
    uint256 public totallBalance= 2500000000 * 1 ether;
    address public creator;
    address public multisigTeamwallet=address(0x0);
    bool public daoSeal =false;
    uint256 public finalQorum=0;
    mapping(address => uint8) public unpausable;
    mapping (address => mapping (address => uint8)) public votes;
    
    mapping (address => uint8) public pauseVote; 
    mapping (address => bool) public isDaoMember;
    
    modifier daoIsNotSealed(){
        require(!daoSeal, "Sealed: no more members");
        _;
    }

    modifier notPaused(address account) {
        require(!paused() || unpausable[account]>finalQorum, "Pausable: paused");
        _;
    }

    modifier isCreator() {
        require(address(msg.sender)==creator, "You are not creator");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    modifier daoMemberDoesNotExist(address daoMember) {
        require(!isDaoMember[daoMember]);
        _;
    }
    modifier daoMemberCheck() {
        require(isDaoMember[msg.sender]);
        _;
    }

    event daoMemberAddition(address indexed daoMember);

    constructor(string memory name, string memory symbol, address multisigTeamwalletOther) payable ERC20(name, symbol) {
        creator=address(msg.sender);
        if(multisigTeamwalletOther != address(0x0) ){
        multisigTeamwallet=multisigTeamwalletOther;
   
            _mint(multisigTeamwallet, totallBalance);
             }
    }



    function sealDaoNow() public isCreator daoIsNotSealed returns(bool){
        if(daoMembers.length>1){
            daoSeal=true;}
    
    return daoSeal;
    }

    function requiredQorum() public view returns(uint256 qorum){
    
    qorum=daoMembers.length/2;

    }

    function addTeamDaoMember(address daoMember)
        public
        daoMemberDoesNotExist(daoMember)
        notNull(daoMember)
        isCreator
        daoIsNotSealed
    {
        isDaoMember[daoMember] = true;
        daoMembers.push(daoMember);
        emit daoMemberAddition(daoMember);
        finalQorum = requiredQorum();
    }

    function addToWhitelist(address[] memory accounts) public daoMemberCheck {
        for(uint8 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0));
            require(votes[accounts[i]][msg.sender]<2);
            votes[accounts[i]][msg.sender]=2;
            unpausable[accounts[i]] = unpausable[accounts[i]] +1;
        }
    }

    function removeFromWhitelist(address[] memory accounts) public daoMemberCheck {
        for(uint8 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0));
            require(votes[accounts[i]][msg.sender]!=1);
            votes[accounts[i]][msg.sender]==1;
            unpausable[accounts[i]] = unpausable[accounts[i]] -1;
        }
    }
    // this is for individual accout address
    function unpausableCheck(address account) public view returns(bool paused){
        if(unpausable[account]>requiredQorum()){
            paused=true;
        }
        else {paused=false;}

    }
    // this is pause for whole Token
    function pauseCheckUp() public daoMemberCheck {
    require(pauseVote[msg.sender]<2);
    pauseVote[msg.sender]=2;
    pauseNow=pauseNow+1;
    } 
    
    function pauseCheckDown() public daoMemberCheck {
    require(pauseVote[msg.sender]!=1);
    pauseVote[msg.sender]=1;
    pauseNow=pauseNow-1;

    } 
    function pausecheck() public view returns(bool checker){
        if(pauseNow>finalQorum){
            return true;
        } else {return false;}
    }

    function pause() public {
    if(pausecheck()){
        _pause();
    }
    }

    function unpause() public {
    if(!pausecheck()){
        _unpause();
    }
    }
/*
    function _burn(address account, uint256 amount) internal override {
        super._burn(account, amount);
        _burnCallback(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        super._transfer(sender, recipient, amount);
        _transferCallback(sender, recipient, amount);
    }
*/
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override notPaused(from) {
        super._beforeTokenTransfer(from, to, amount);
    }

}
