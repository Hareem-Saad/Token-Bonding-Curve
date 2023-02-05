// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "contracts/TokenBondingCurve_Linear.sol";
import "lib/forge-std/src/Test.sol";


contract TokenBondingCurve_LinearTest is Test {
    TokenBondingCurve_Linear public tbcl;        
    uint256 MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;        
    uint256 HUN_INT = (2**256 - 1) - 100;        
    address user = address(1);

    function setUp() public {
        tbcl = new TokenBondingCurve_Linear("alphabet", "abc", 2);
    }

    function testBuy() public {
        uint amount = 5;
        uint oldBal = address(tbcl).balance;
        uint val = tbcl.calculatePriceForBuy(amount);
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        tbcl.buy{value: val}(amount);
        assertEq(tbcl.totalSupply(), amount);
        assertEq(address(tbcl).balance, oldBal + val);
        vm.stopPrank();
    }

    function testFail_Buy() public {
        // bytes calldata err = bytes("LowOnEther(0, 0)");
        // vm.expectRevert(err);
        // vm.expectRevert(
        //     abi.encodeWithSelector(LowOnEther.selector, 0, 0)
        // );
        vm.expectRevert("LowOnEther(0, 0)");
        vm.startPrank(user);
        tbcl.buy(5);
        vm.stopPrank();
    }

    function testBuy_withFuzzing(uint amount) public {
        // vm.assume(amount > 40000050 && amount < 50000000);
        vm.assume(amount > 0 && amount < 100);
        uint oldBal = address(tbcl).balance;
        uint val = tbcl.calculatePriceForBuy(amount);
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        tbcl.buy{value: val}(amount);
        assertEq(tbcl.totalSupply(), amount);
        assertEq(address(tbcl).balance, oldBal + val);
        vm.stopPrank();
    }

    // function testBuy_withBigFuzzing(uint amount) public {
    //     vm.assume(amount >= HUN_INT && amount <= MAX_INT);
    //     uint oldBal = address(tbcl).balance;
    //     uint val = tbcl.calculatePriceForBuy(amount);
    //     vm.deal(user, 1 ether);
    //     vm.startPrank(user);
    //     tbcl.buy{value: val}(amount);
    //     assertEq(tbcl.totalSupply(), amount);
    //     assertEq(address(tbcl).balance, oldBal + val);
    //     vm.stopPrank();
    // }
}
