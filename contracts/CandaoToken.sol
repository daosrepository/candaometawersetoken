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
contract CandaoToken is ERC20, ERC20Burnable, Pausable, RecoverableFunds, WithCallback {

    mapping(address => bool) public unpausable;
    mapping (address => mapping (address => uint8)) public votes;
    
    mapping (address => uint8) public pauseVote; 
    
    uint256 pauseNow=0;

    address public creator;
    bool public daoSeal =false;

    modifier daoIsNotSealed(){
        require(!daoSeal, "Sealed: no more members");
        _;
    }

    modifier notPaused(address account) {
        require(!paused() || unpausable[account]>requiredQorum, "Pausable: paused");
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

    constructor(string memory name, string memory symbol, address[] memory initialAccounts, uint256[] memory initialBalances) payable ERC20(name, symbol) {
        creator=address(msg.sender);
        for(uint8 i = 0; i < initialAccounts.length; i++) {
            _mint(initialAccounts[i], initialBalances[i]);
        }
    }

    mapping (address => bool) public isDaoMember;
    address[] public daoMembers;

    function sealDaoNow() public isCreator daoIsNotSealed returns(bool){
        if(daoMembers.length>1){
            daolSeal=true;}
    
    return daolSeal;
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
        if(pauseNow>qorum){
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
