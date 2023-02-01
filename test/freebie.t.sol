// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/other/Token.sol";
import "../src/freebie/GovToken.sol";
import "../src/freebie/RewardsAdvisor.sol";
import "../src/freebie/Exploit.sol";

contract freebie is Test {
    address internal attacker;
    address internal deployer;
    address payable internal  user;
    
    GovToken internal govtoken;
    Token internal farm;
    RewardsAdvisor internal rewardsadvisor;
    Exploit internal exploit;

    uint256 internal constant ATTACKER_INIT_FARM_TOKEN_AMOUNT = 1e18;
    uint256 internal constant USER_INIT_FARM_TOKEN_AMOUNT = 10000e18;

    
    function setUp() public {
        /******************************************
        *                   INFO                  *
        *             Some EOA address            *
        *******************************************/
        
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");
        
        user = payable(address(bytes20("user")));
        vm.label(user, "User");

        deployer = address(bytes20("deployer"));
        vm.label(deployer, "Deployer");

        /******************************************
        *                  INFO                   *
        *            Deploy  contracts            *
        *******************************************/

        vm.startPrank(deployer);
        // deploying `FARM` token contract
        farm = new Token('FARM','FARM');
        vm.label(address(farm), "FarmToken");
        
        address[] memory farmTokenRecipients = new address[](2);
        farmTokenRecipients[0] = user;
        farmTokenRecipients[1] = attacker;

        uint256[] memory farmTokenAmounts = new uint256[](2);
        farmTokenAmounts[0] = USER_INIT_FARM_TOKEN_AMOUNT;
        farmTokenAmounts[1] = ATTACKER_INIT_FARM_TOKEN_AMOUNT; // attacker gets 1

        farm.mintPerUser(farmTokenRecipients, farmTokenAmounts);
        
        // deploying protocol contracts
        govtoken = new GovToken('xFARM','xFARM');
        vm.label(address(govtoken), "GovToken:xFARM");

        rewardsadvisor = new RewardsAdvisor(address(farm), address(govtoken));
        vm.label(address(rewardsadvisor), "RewardsAdvisor");
        govtoken.transferOwnership(address(rewardsadvisor));
        vm.stopPrank();

        vm.startPrank(user);
        // other user stakes their `FARM` token
        farm.approve(address(rewardsadvisor), type(uint256).max);
        rewardsadvisor.deposit(USER_INIT_FARM_TOKEN_AMOUNT, user, user);
        vm.stopPrank();
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
        
        // attacker drains 99.99%+ of the `FARM` tokens from RewardsAdvisor staking contract
        assertGe(farm.balanceOf(attacker), USER_INIT_FARM_TOKEN_AMOUNT);
        assertLe(farm.balanceOf(address(rewardsadvisor)), 1e18);
    }

}