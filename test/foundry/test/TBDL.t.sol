// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/forge-std/src/Test.sol";
import "contracts/TokenBondingCurve_Linear.sol";


contract TokenBondingCurve_LinearTest is Test {
    TokenBondingCurve_Linear public tbcl;

    function setUp() public {
        tbcl = new TokenBondingCurve_Linear("alphabet", "abc", "2");
    }

    function testBuy() public {
        uint val = tbcl.calculatePriceForBuy(5);
        tbcl.buy{value: val}(5);
        assertEq(counter.totalSupply(), 5);
        assertEq(address(this).balance, val);
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
