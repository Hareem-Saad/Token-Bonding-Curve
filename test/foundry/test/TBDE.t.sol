// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "contracts/TokenBondingCurve_Exponential.sol";
import "lib/forge-std/src/Test.sol";


contract TokenBondingCurve_ExponentialTest is Test {
    TokenBondingCurve_Exponential public tbce;     
    address user = address(1);
    address deployer = address(100);
    event tester(uint);

    function setUp() public {
        vm.prank(deployer);
        tbce = new TokenBondingCurve_Exponential("alphabet", "abc", 2);
    }

    function testBuy() public {
        uint amount = 5;
        uint oldBal = address(tbce).balance;
        uint val = tbce.calculatePriceForBuy(amount);
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        tbce.buy{value: val}(amount);
        assertEq(tbce.totalSupply(), amount);
        assertEq(address(tbce).balance, oldBal + val);
        vm.stopPrank();
    }

    function testCannot_Buy() public {
        // bytes calldata err = bytes("LowOnEther(0, 0)");
        // vm.expectRevert(err);
        vm.expectRevert(
            abi.encodeWithSelector(LowOnEther.selector, 0, 0)
        );
        // vm.expectRevert("LowOnEther(0, 0)");
        vm.startPrank(user);
        tbce.buy(5);
        vm.stopPrank();
    }

    function testBuy_withFuzzing(uint amount) public {
        // vm.assume(amount > 40000050 && amount < 50000000);
        vm.assume(amount > 0 && amount < 900000000000);
        uint oldBal = address(tbce).balance;
        uint val = tbce.calculatePriceForBuy(amount);
        vm.deal(user, 1000000000000000000000000000000000000 ether);
        vm.startPrank(user);
        tbce.buy{value: val}(amount);
        assertEq(tbce.totalSupply(), amount);
        assertEq(address(tbce).balance, oldBal + val);
        vm.stopPrank();
    }

    function testSystem_withFuzzing(uint amount) public {
        // vm.assume(amount > 40000050 && amount < 50000000);
        //assumptions
        
        vm.assume(amount > 0 && amount <= 900000000000);

        //save some variables
        uint oldBal = address(tbce).balance;
        uint val = tbce.calculatePriceForBuy(amount);

        //deal user some ether
        vm.deal(user, 1000000000000000000000000000000000000 ether); 

        //start
        vm.prank(user);

        //*****************************************************************
        //buy tkns
        tbce.buy{value: val}(amount);

        //read from slot zero to find out tax
        // bytes32 _tax = vm.load(address(tbce), bytes32(uint256(0)));
        // uint256 tax = (uint256(_tax));

        //check if total supply increases
        assertEq(tbce.totalSupply(), amount);

        //check if balance increases
        assertEq(address(tbce).balance, oldBal + val);

        //check if tax is zero
        vm.prank(deployer);
        assertEq(tbce.viewTax(), 0);

        oldBal = address(tbce).balance;

        //*****************************************************************
        //buy 10 more tokens
        uint price1 = tbce.calculatePriceForBuy(10);
        vm.prank(user);
        tbce.buy{value: price1}(10);

        //check if total supply increases
        assertEq(tbce.totalSupply(), amount + 10);

        //check if balance increases
        assertEq(address(tbce).balance, oldBal + price1);

        //check if tax is zero
        vm.prank(deployer);
        assertEq(tbce.viewTax(), 0);

        oldBal = address(tbce).balance;

        //*****************************************************************
        //sell 5 tokens
        uint cs = tbce.totalSupply();

        uint price2 = tbce.calculatePriceForSell(5);
        vm.prank(user);
        tbce.sell(5);

        //find out tax
        vm.prank(deployer);
        uint tax = tbce.viewTax();

        //TODO: fix assertions from here
        //check if total supply increases
        assertEq(tbce.totalSupply(), cs - 5);

        //check if balance decreases
        assertEq(address(tbce).balance, oldBal - price2 + tax);

        //check if tax is not zero
        assertEq(tax, ((price2 * 1000) / 10000));

        //*****************************************************************
        //sell rest of tokens
        uint price3 = tbce.calculatePriceForSell(tbce.totalSupply());
        uint ts = tbce.totalSupply();
        vm.prank(user);
        tbce.sell(ts);

        //find out tax
        vm.prank(deployer);
        tax = tbce.viewTax();

        //check if total supply decreases
        assertEq(tbce.totalSupply(), 0);

        //check if tax is not zero
        assertEq(tax, ((price3 * 1000) / 10000) + ((price2 * 1000) / 10000));

        //check if balance decreases
        assertEq(address(tbce).balance, tax);

        //*****************************************************************
        uint oldOwnerBal = deployer.balance;
        vm.prank(deployer);
        tbce.withdraw();
        emit tester(deployer.balance);
        assertEq(deployer.balance, oldOwnerBal + tax);

    }

    function testCannot_Sell() public {
        vm.expectRevert(
            abi.encodeWithSelector(LowOnTokens.selector, 6, 0)
        );
        vm.startPrank(user);
        tbce.sell(6);
        vm.stopPrank();
    }

    function testCannot_Withdraw() public {
        vm.expectRevert(
            abi.encodeWithSelector(LowOnEther.selector, 0, 0)
        );
        vm.startPrank(deployer);
        tbce.withdraw();
        vm.stopPrank();
    }
}
