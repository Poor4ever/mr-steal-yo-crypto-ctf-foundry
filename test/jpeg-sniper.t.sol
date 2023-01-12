// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/jpeg-sniper/FlatLaunchpeg.sol";
import "../src/jpeg-sniper/Exploit.sol";

contract jpegSniper is Test {
    uint internal blockNumber;
    uint256 internal constant COLLECTION_SIZE = 69;
    uint256 internal constant MAX_BATCH_SIZE = 5;
    uint256 internal constant MAX_PER_ADDRESS_DURING_MINT = 5;

    address internal attacker;
    FlatLaunchpeg internal flatlaunchpeg;
    Exploit internal exploit;

    function setUp() public {
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");

        flatlaunchpeg = new FlatLaunchpeg(COLLECTION_SIZE, MAX_BATCH_SIZE, MAX_PER_ADDRESS_DURING_MINT);
        vm.label(address(flatlaunchpeg), "FlatLaunchpeg");

        blockNumber = block.number;
    }

    function testExploit() public {
        vm.startPrank(attacker);
        //Deploy your exploit contract and complete the challenge!
        exploit = new Exploit(address(flatlaunchpeg));
        vm.stopPrank();
        verify();
    }

    function verify() internal {
        assertEq(flatlaunchpeg.balanceOf(attacker), 69);
        assertEq(flatlaunchpeg.totalSupply(), 69);
    }
}
