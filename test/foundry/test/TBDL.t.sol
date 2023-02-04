// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "contracts/TokenBondingCurve_Linear.sol";
import "lib/forge-std/src/Test.sol";


contract TokenBondingCurve_LinearTest is Test {
    TokenBondingCurve_Linear public tbcl;

    function setUp() public {
        tbcl = new TokenBondingCurve_Linear("alphabet", "abc", 2);
    }

    function testBuy() public {
        // uint val = tbcl.calculatePriceForBuy(5);
        console.log("0");
        tbcl.buy{value: 0.00000000000000003 ether}(5);
        console.log("1");
        assertEq(tbcl.totalSupply(), 5);
        console.log("2");
        assertEq(address(this).balance, 30 wei);
        console.log("3");
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
