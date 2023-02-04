// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "Foundry_Testing/lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/Script.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
