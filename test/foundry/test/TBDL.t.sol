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
        vm.assume(amount > 0);
        vm.assume(amount < 900000);
        uint oldBal = address(tbcl).balance;
        uint val = tbcl.calculatePriceForBuy(amount);
        vm.deal(user, 1000000000000000000000000000000000000 ether);
        vm.startPrank(user);
        tbcl.buy{value: val}(amount);
        assertEq(tbcl.totalSupply(), amount);
        assertEq(address(tbcl).balance, oldBal + val);
        vm.stopPrank();
    }

    function testBuyAndSell_withFuzzing(uint amount) public {
        // vm.assume(amount > 40000050 && amount < 50000000);
        //assumptions
        vm.assume(amount > 0);

        //save some variables
        uint oldBal = address(tbcl).balance;
        uint val = tbcl.calculatePriceForBuy(amount);

        //deal user some ether
        vm.deal(user, 1000000000000000000000000000000000000 ether); 

        //start
        vm.startPrank(user);

        //*****************************************************************
        //buy tkns
        tbcl.buy{value: val}(amount);

        //read from slot zero to find out tax
        bytes32 _tax = vm.load(address(tbcl), bytes32(uint256(0)));
        uint256 tax = (uint256(_tax));

        //check if total supply increases
        assertEq(tbcl.totalSupply(), amount);

        //check if balance increases
        assertEq(address(tbcl).balance, oldBal + val);

        //check if tax is zero
        assertEq(tax, 0);

        oldBal = address(tbcl).balance;

        //*****************************************************************
        //buy 10 more tokens
        uint price1 = tbcl.calculatePriceForBuy(10);
        tbcl.buy{value: price1}(10);

        //read from slot zero to find out tax
        _tax = vm.load(address(tbcl), bytes32(uint256(0)));
        tax = (uint256(_tax));

        //check if total supply increases
        assertEq(tbcl.totalSupply(), amount + 10);

        //check if balance increases
        assertEq(address(tbcl).balance, oldBal + price1);

        //check if tax is zero
        assertEq(tax, 0);

        //*****************************************************************
        //sell 5 tokens
        uint cs = tbcl.totalSupply();

        uint price2 = tbcl.calculatePriceForSell(5);
        tbcl.sell(5);

        //read from slot zero to find out tax
        _tax = vm.load(address(tbcl), bytes32(uint256(0)));
        tax = (uint256(_tax));

        //check if total supply increases
        assertEq(tbcl.totalSupply(), cs - 5);

        //check if balance decreases
        assertEq(address(tbcl).balance, address(tbcl).balance - price2);
        console.log(3);

        //check if tax is not zero
        assertEq(tax, ((price2 * 1000) / 10000));
        console.log(4);

        //*****************************************************************
        //sell rest of tokens
        uint price3 = tbcl.calculatePriceForSell(tbcl.totalSupply());
        tbcl.sell(tbcl.totalSupply());

        //read from slot zero to find out tax
        _tax = vm.load(address(tbcl), bytes32(uint256(0)));
        tax = (uint256(_tax));

        //check if total supply decreases
        assertEq(tbcl.totalSupply(), 0);

        //check if tax is not zero
        assertEq(tax, ((price3 * 1000) / 10000));

        //check if balance decreases
        assertEq(address(tbcl).balance, tax);

        
        vm.stopPrank();
    }
}
