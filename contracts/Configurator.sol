// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./RecoverableFunds.sol";
import "./CandaoToken.sol";
import "./VestingWallet.sol";

contract Configurator is RecoverableFunds {
    using Address for address;

    VestingWallet public wallet;

    constructor(address owner) {
        // create wallet
        wallet = new VestingWallet();
        // set percent rate
        wallet.setPercentRate(1000);
        // groups
        wallet.addGroup(1);     // Seed round
        wallet.addGroup(2);     // Round I
        wallet.addGroup(3);     // Round II
        wallet.addGroup(4);     // Ecosystem rewards pool
        wallet.addGroup(5);     // Candao foundation
        wallet.addGroup(6);     // Liquidity pools & reserves
        wallet.addGroup(7);     // Team
        wallet.addGroup(8);    // Strategic partnerships
        wallet.addGroup(9);    // Advisors
        wallet.addGroup(10);    // Marketing
        // vesting schedules
        // investors
        wallet.setVestingSchedule(1,  24 weeks, 104 weeks, 1 weeks, 100);
        wallet.setVestingSchedule(2,  12 weeks, 104 weeks, 1 weeks, 100);
        wallet.setVestingSchedule(3,   4 weeks, 104 weeks, 1 weeks, 200);
        // ecosystem
        wallet.setVestingSchedule(4,   4 weeks, 208 weeks, 1 weeks, 15);
        wallet.setVestingSchedule(5,   4 weeks, 108 weeks, 1 weeks, 10);
        wallet.setVestingSchedule(6,   0 weeks, 208 weeks, 1 weeks, 20);
        // internal
        wallet.setVestingSchedule(7,   36 weeks, 144 weeks, 1 weeks, 30);
        wallet.setVestingSchedule(8,   24,        96 weeks, 1 weeks, 50);
        wallet.setVestingSchedule(9,   36 weeks,  96 weeks, 1 weeks, 50);
        wallet.setVestingSchedule(10,  12,       144 weeks, 1 weeks, 50);

        wallet.transferOwnership(owner);
    }

}