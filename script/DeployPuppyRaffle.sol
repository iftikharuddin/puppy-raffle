// SPDX-License-Identifier: MIT
pragma solidity 0.7.6; // @audit The contract is written in Solidity version 0.7.6. It's usually a good idea to use the newest version of Solidity because it has security improvements and updates. But if you're using an older version that is known to be safe, it's not necessarily a security problem

import {Script} from "forge-std/Script.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";

contract DeployPuppyRaffle is Script {
    uint256 entranceFee = 1e18;
    address feeAddress;
    uint256 duration = 1 days;

    function run() public {
        feeAddress = msg.sender;

        vm.broadcast();
        PuppyRaffle puppyRaffle =
        new PuppyRaffle( // @audit unused local variable puppyRaffle but this contract is OUT of Scope!
            1e18,
            feeAddress,
            duration
        );
    }
}
