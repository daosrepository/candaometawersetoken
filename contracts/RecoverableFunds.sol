// SPDX-License-Identifier: all rights reserved

pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20Cutted.sol";
//import "@openzeppelin/constracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @dev Allows the owner to retrieve ETH or tokens sent to this contract by mistake.
 */

contract RecoverableFunds is Ownable {

    function retriveETH(address payable recipient) public virtual onlyOwner {
        recipient.transfer(address(this).balance);
    }
    
    function retrieveTokens(address recipient, address anotherToken) public virtual onlyOwner {
     IERC20Cutted alienToken = IERC20Cutted(anotherToken);
      alienToken.transfer(recipient, alienToken.balanceOf(address(this)));
    }



}


