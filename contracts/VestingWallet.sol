// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.1;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IERC20Cutted.sol";
import "./RecoverableFunds.sol";
import "./CandaoToken.sol";
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
//import "../../../utils/Address.sol";

contract VestingWallet is Pausable, RecoverableFunds {

    using SafeMath for uint256;

    using Address for address;

    struct VestingSchedule {
        uint256 delay;      // the amount of time before vesting starts
        uint256 duration;
        uint256 interval;
        uint256 unlocked;   // percentage of initially unlocked tokens
    }

    struct Balance {
        uint256 initial;
        uint256 withdrawn;
    }

    struct AccountInfo {
        uint256 initial;
        uint256 withdrawn;
        uint256 vested;
    }

  


    IERC20Cutted public token;
    uint256 public percentRate = 100;
    bool public isWithdrawalActive = false;
    uint256 public withdrawalStartDate;
    mapping(uint8 => VestingSchedule) public vestingSchedules;
    mapping(uint8 => mapping(address => Balance)) public balances;
    uint8[] public groups;

   mapping(address => bool) public unpausable;
    mapping (address => mapping (address => uint8)) public votes;
    mapping (uint8 => uint8) public votesForTopicsCount; // 1 withdrawal
    mapping (address => bool) public votesForTopicsDone; 
    
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

    event Withdrawal(address account, uint256 value);
    event WithdrawalIsActive();
    event setedToken(address setedTokenAddress);
    event setedPercentRate(uint256 value);
    event setedBalance(uint256 indexed group, address indexed account, uint256 initial, uint256 withdrawn);
    event addedBalance(uint256 indexed group, address indexed account, uint256 initial);
    event addedGroup(uint256 indexed group,uint256 vestingSchedule);
    event updatedGroup(uint256 indexed group, uint8 vestingSchedule);
    event deletedGroup(uint256 group);

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

    function setToken(address newTokenAddress) public isCreator returns(address tokenA){
        tokenA =address(token);
        if(!(tokenA!=address(0x0))){
        token = IERC20Cutted(newTokenAddress);
        emit setedToken(newTokenAddress);
        return tokenA = address(token);
        }
    }


    function setPercentRate(uint256 newPercentRate) public isCreator daoIsNotSealed {
        percentRate = newPercentRate; // percentRate is only for Unlocking initial tokens
        emit setedPercentRate(newPercentRate);
    }


    function activateWithdrawal() public onlyOwner {
        require(!isWithdrawalActive, "VestingWallet:  withdrawal is already enabled ");
        require(!votesForTopicsDone, "VestingWallet: you already voted to enable withdrawal ");

    votesForTopicsDone[msg.sender]=true;
    votesForTopicsCount[1]=votesForTopicsCount[1]+1; // 1st topic - withdrawal
       if(isWithdrawalActiveCheck()){
           isWithdrawalActive=true;
        withdrawalStartDate = block.timestamp;
        emit WithdrawalIsActivated();
       }
    }

function isWithdrawalActiveCheck() public view return(bool active){

if(votesForTopicsCount[1]>requiredQorum()){
    return active=true;
} else {
    return active=false;
    }
}
    
    function requiredQorum() public view returns(uint256 qorum){
    
    qorum=daoMembers.length/2;

    }


    function setBalance(uint8 group, address account, uint256 initial, uint256 withdrawn) public isCreator {
        Balance storage balance = balances[group][account];
        balance.initial = initial;
        balance.withdrawn = withdrawn;
        emit setedBalance(group,account,initial,withdrawn);
    }

    function addBalances(uint8 group, address[] calldata addresses, uint256[] calldata amounts) public isCreator {
        require(addresses.length == amounts.length, "VestingWallet: incorrect array length");
        for (uint256 i = 0; i < addresses.length; i++) {
            Balance storage balance = balances[group][addresses[i]];
            balance.initial = balance.initial.add(amounts[i]);
            emit addedBalance(group,addresses[i],amounts[i]);
        }
    }

    function setVestingSchedule(uint8 index, uint256 delay, uint256 duration, uint256 interval, uint256 unlocked) public isCreator {
        VestingSchedule storage schedule = vestingSchedules[index];
        schedule.delay = delay;
        schedule.duration = duration;
        schedule.interval = interval;
        schedule.unlocked = unlocked;
    }



    function addGroup(uint8 vestingSchedule) public isCreator {
        require(groups.length < type(uint256).max, "VestingWallet: the maximum number of groups has been reached");
        groups.push(vestingSchedule);
        uint256 indexGroup=groups.length;
        emit addedGroup(indexGroup,vestingSchedule);
    }
    // czy to nie powinno byc vesting uint 256 ? co jest wieksze
    function updateGroup(uint256 index, uint8 vestingSchedule) public isCreator {
        require(index < groups.length, "VestingWallet: wrong group index");
        groups[index] = vestingSchedule;
        emit updatedGroup(index,vestingSchedule);
    }

    function deleteGroup(uint256 index) public isCreator {
        require(index < groups.length, "VestingWallet: wrong group index");
        for (uint256 i = index; i < groups.length - 1; i++) {
            groups[i] = groups[i + 1];
        }
        groups.pop();
    // czy to dziala ? dobrze i jak dziala to trzeba uwzglednic potem wpisywanie vestingu ludziom w nowym indeksie grup
     emit  deletedGroup(index);

    }

    function groupsCount() public view returns (uint256) {
        return groups.length;
    }

    function calculateVestedAmount(Balance memory balance, VestingSchedule memory schedule) internal view returns (uint256) {
        if (block.timestamp < withdrawalStartDate.add(schedule.delay)) return 0;
        uint256 tokensAvailable;
        if (block.timestamp >= withdrawalStartDate.add(schedule.delay).add(schedule.duration)) {
            tokensAvailable = balance.initial;
        } else {
            uint256 parts = schedule.duration.div(schedule.interval);
            uint256 tokensByPart = balance.initial.div(parts);
            uint256 timeSinceStart = block.timestamp.sub(withdrawalStartDate).sub(schedule.delay);
            uint256 pastParts = timeSinceStart.div(schedule.interval);
            uint256 initiallyUnlocked = balance.initial.mul(schedule.unlocked).div(percentRate);
            tokensAvailable = tokensByPart.mul(pastParts).add(initiallyUnlocked);
        }
        return tokensAvailable.sub(balance.withdrawn);
    }

    function getAccountInfo(address account) public view returns (AccountInfo memory) {
        uint256 initial;
        uint256 withdrawn;
        uint256 vested;
        for (uint8 groupIndex = 0; groupIndex < groups.length; groupIndex++) {
            Balance memory balance = balances[groupIndex][account];
            VestingSchedule memory schedule = vestingSchedules[groups[groupIndex]];
            uint256 vestedAmount = calculateVestedAmount(balance, schedule);
            initial = initial.add(balance.initial);
            withdrawn = withdrawn.add(balance.withdrawn);
            vested = vested.add(vestedAmount);
        }
        return AccountInfo(initial, withdrawn, vested);
    }

    function withdraw() public whenNotPaused {
        require(isWithdrawalActive, "VestingWallet: withdrawal is not yet active");
        uint256 tokensToSend;
        for (uint8 groupIndex = 0; groupIndex < groups.length; groupIndex++) {
            Balance storage balance = balances[groupIndex][_msgSender()];
            if (balance.initial > 0) {
                VestingSchedule memory schedule = vestingSchedules[groups[groupIndex]];
                uint256 vestedAmount = calculateVestedAmount(balance, schedule);
                if (vestedAmount > 0) {
                    balance.withdrawn = balance.withdrawn.add(vestedAmount);
                    tokensToSend = tokensToSend.add(vestedAmount);
                }
            }
        }
        require(tokensToSend > 0, "VestingWallet: there are no assets that could be withdrawn from your account");
        safeTransfer(token,_msgSender(), tokensToSend);
        emit Withdrawal(_msgSender(), tokensToSend);
    }
    function safeTransfer(
        IERC20Cutted tokenIn,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(tokenIn, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function _callOptionalReturn(IERC20Cutted token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

