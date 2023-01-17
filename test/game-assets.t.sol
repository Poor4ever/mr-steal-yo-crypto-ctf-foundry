// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/game-assets/GameAsset.sol";
import "../src/game-assets/AssetWrapper.sol";
import "../src/game-assets/Exploit.sol";


contract gameAssets is Test {
    address internal attacker;
    address internal deployer;
    address internal adminUser;

    GameAsset internal swordasset;
    GameAsset internal shieldasset;
    AssetWrapper internal assetwrapper;
    Exploit internal exploit;
    
    function setUp() public {
        /******************************************
        *                   INFO                  *
        *             Some EOA address            *
        *******************************************/
        
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");
        
        adminUser = address(bytes20("adminUser"));
        vm.label(address(adminUser), "AdminUser");

        deployer = address(bytes20("deployer"));
        vm.label(address(deployer), "Deployer");

        /******************************************
        *                  INFO                   *
        *            Deploy  contracts            *
        *******************************************/

        vm.startPrank(deployer);
        assetwrapper = new AssetWrapper("https://twitter.com/0xpoor4ever");
        swordasset = new GameAsset("SWORD", "SWORD");
        shieldasset = new GameAsset("SHIELD", "SHIELD");
        vm.label(address(assetwrapper), "AssetWrapper");
        vm.label(address(swordasset), "GameAsset:SWORD");
        vm.label(address(shieldasset), "GameAsset:SHIELD");

        // whitelist the two assets for use in the game
        assetwrapper.updateWhitelist(address(swordasset));
        assetwrapper.updateWhitelist(address(shieldasset));

        // set the operator of the two game assets to be the wrapper contract
        swordasset.setOperator(address(assetwrapper));
        shieldasset.setOperator(address(assetwrapper));

        // adminUser is the user you will be griefing
        // minting 1 SWORD & 1 SHIELD asset for adminUser
        swordasset.mintForUser(adminUser, 1);
        shieldasset.mintForUser(adminUser, 1);

        //verify
        assertEq(swordasset.balanceOf(adminUser), 1);
        assertEq(shieldasset.balanceOf(adminUser), 1);
        vm.stopPrank();
    }
    
    function testExploit() public {
        vm.startPrank(attacker);
        exploit = new Exploit([address(swordasset), address(shieldasset)], address(assetwrapper));
        exploit.start();
        vm.stopPrank();
        verify();
    }

    function verify() internal {
        /******************************************
        *                 INFO                    *
        *    Verify completion of the challenge   *
        *******************************************/
        
        // attacker traps user's SWORD and SHIELD NFTs inside assetWrapper contract
        assertEq(swordasset.balanceOf(adminUser), 0);
        assertEq(shieldasset.balanceOf(adminUser), 0);
        
        assertEq(swordasset.balanceOf(address(assetwrapper)), 1);
        assertEq(shieldasset.balanceOf(address(assetwrapper)), 1);

        assertEq(assetwrapper.balanceOf(adminUser, 0), 0);
        assertEq(assetwrapper.balanceOf(adminUser, 1), 0);
    }
}

