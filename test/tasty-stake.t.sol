// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/other/Token.sol";
import "../src/tasty-stake/TastyStaking.sol";
import "../src/tasty-stake/Exploit.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract tastyStake is Test {
    address internal attacker;
    address internal deployer;
    address internal user;
    
    uint256 internal constant ATTACKER_INIT_STEAK_TOKEN_AMOUNT = 1e18;
    uint256 internal constant USER_INIT_STEAK_TOKEN_AMOUNT = 100000e18;
    uint256 internal constant DEPLOYER_INIT_BUTTER_TOKEN_AMOUNT = 10000e18;

    
    Token internal steak;
    Token internal butter;
    TastyStaking internal tastystaking;
    Exploit internal exploit;

    function setUp() public {
        /******************************************
        *                   INFO                  *
        *             Some EOA address            *
        *******************************************/
    
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");

        deployer = address(bytes20("deployer"));
        vm.label(deployer, "Deployer");

        user = address(bytes20("user"));
        vm.label(user, "User");
        
        vm.startPrank(deployer);
        steak = new Token('STEAK', 'STEAK'); // staking token
        vm.label(address(steak), "STEAK:StakeToken");
        
        address[] memory stakeTokenRecipients = new address[](2);
        stakeTokenRecipients[0] = attacker;
        stakeTokenRecipients[1] = user;

        uint256[] memory stakeTokenAmounts = new uint256[](2);
        stakeTokenAmounts[0] = ATTACKER_INIT_STEAK_TOKEN_AMOUNT; // attacker gets 1 steak
        stakeTokenAmounts[1] = USER_INIT_STEAK_TOKEN_AMOUNT; 
        steak.mintPerUser(stakeTokenRecipients, stakeTokenAmounts);
        
        butter = new Token('BUTTER', 'BUTTER'); // reward token
        vm.label(address(butter), "BUTTER:RewardToken");
        
        address[] memory rewardTokenRecipient = new address[](1);
        rewardTokenRecipient[0] = deployer;

        uint256[] memory rewardTokenAmounts = new uint256[](2);
        rewardTokenAmounts[0] = DEPLOYER_INIT_BUTTER_TOKEN_AMOUNT;
        butter.mintPerUser(rewardTokenRecipient, rewardTokenAmounts);

        tastystaking = new TastyStaking(address(steak), address(deployer));
        
        // setting up the rewards for tastyStaking
        tastystaking.addReward(address(butter));
        butter.approve(address(tastystaking), DEPLOYER_INIT_BUTTER_TOKEN_AMOUNT);
        tastystaking.notifyRewardAmount(address(butter), DEPLOYER_INIT_BUTTER_TOKEN_AMOUNT);
        vm.stopPrank();
        // other user stakes initial amount of steak
        vm.startPrank(user);
        steak.approve(address(tastystaking), type(uint256).max);
        tastystaking.stakeAll();
        vm.stopPrank();
        
        // advance time by an hour
        vm.warp(block.timestamp + 3600);
        vm.roll(block.number + 1);
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
        
        // attacker drains all staking tokens from tastyStaking contract
        assertEq(IERC20(steak).balanceOf(address(tastystaking)), 0);
        assertGe(IERC20(steak).balanceOf(address(attacker)), DEPLOYER_INIT_BUTTER_TOKEN_AMOUNT);
    }
}