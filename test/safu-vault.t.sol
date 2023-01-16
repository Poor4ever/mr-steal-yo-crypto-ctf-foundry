// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/other/Token.sol";
import "../src/safu-vault/SafuStrategy.sol";
import "../src/safu-vault/SafuVault.sol";
import "../src/safu-vault/Exploit.sol";

contract safuVault is Test {
    address internal attacker;
    address internal usdcAdmin;
    address internal deployer;

    Token internal usdc;
    SafuStrategy internal safustrategy;
    SafuVault internal safuvault;
    Exploit internal exploit;

    uint256 internal constant USERS_FUND = 10000e18;
    uint256 internal constant ATTACKER_INIT_FUND = 10000e18;
    
    
    function setUp() public {
        /******************************************
        *                   INFO                  *
        *             Some EOA address            *
        *******************************************/
        
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");
        
        usdcAdmin = address(bytes20("usdcAdmin"));
        vm.label(address(usdcAdmin), "UsdcAdmin");

        deployer = address(bytes20("deployer"));
        vm.label(address(deployer), "Deployer");

        
        /******************************************
        *                   INFO                  *
        *            Deploy  contracts            *
        *******************************************/
        
        //Deploy USDC Contract and Allocate Funds
        vm.startPrank(usdcAdmin);
        usdc = new Token('USDC','USDC');
        
        address[] memory recipients = new address[](2);
        recipients[0] = attacker;
        recipients[1] = deployer;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = ATTACKER_INIT_FUND;
        amounts[1] = USERS_FUND;

        usdc.mintPerUser(recipients, amounts);
        vm.stopPrank();
        vm.label(address(usdc), "USDC");

        //Deploy SafuStrategy and SafeuVault and deposit user funds
        vm.startPrank(deployer);
        safustrategy = new SafuStrategy(address(usdc));
        safuvault = new SafuVault(IStrategy(address(safustrategy)), 'LP Token', 'LP');

        safustrategy.setVault(address(safuvault));
        usdc.approve(address(safuvault), type(uint256).max);
        safuvault.depositAll();
        vm.stopPrank();
        vm.label(address(safustrategy), "SafuStrategy");
        vm.label(address(safuvault), "SafuVault");
    }
    
    function testExploit() public {
        vm.startPrank(attacker);
        //Deploy your exploit contract and complete the challenge!
        exploit = new Exploit();
        vm.stopPrank();
        verify();
    }

    function verify() internal {
        /******************************************
        *                 INFO                    *
        *    Verify completion of the challenge   *
        *******************************************/
        
        // attacker drains >= 90% of funds
        uint totalVaultFunds = usdc.balanceOf(address(safuvault)) + usdc.balanceOf(address(safustrategy));
        assertLe(totalVaultFunds, 1000e18); 
        assertGe(usdc.balanceOf(attacker), 19000e18);
    }
}

