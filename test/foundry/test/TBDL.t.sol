// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "contracts/TokenBondingCurve_Linear.sol";
import "lib/forge-std/src/Test.sol";


contract TokenBondingCurve_LinearTest is Test {
    TokenBondingCurve_Linear public tbcl;                      
    address user = address(1);

    function setUp() public {
        tbcl = new TokenBondingCurve_Linear("alphabet", "abc", 2);
    }

    function testBuy() public {
        uint oldBal = address(tbcl).balance;
        uint val = tbcl.calculatePriceForBuy(5);
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        tbcl.buy{value: val}(5);
        assertEq(tbcl.totalSupply(), 5);
        assertEq(address(tbcl).balance, oldBal + 30);
        vm.stopPrank();
    }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
