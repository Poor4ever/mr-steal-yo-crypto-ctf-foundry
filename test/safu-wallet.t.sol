pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/safu-wallet/safuWallet.sol";
import "../src/safu-wallet/ISafuWalletLibrary.sol";

contract safuWallet is Test {
    address internal attacker;
    address internal deployer;
    address internal walletOwner;
    
    uint256 internal constant DEPLOYER_INIT_ETH_AMOUNT = 100 ether;

    SafuWallet internal safuwallet;
    IsafuWalletLibrary internal safuwalletlibray;
    

    function setUp() public {
        /******************************************
        *                   INFO                  *
        *             Some EOA address            *
        *******************************************/
        
        attacker = address(bytes20("attacker"));
        vm.label(attacker, "Attacker");
        
        walletOwner = address(bytes20("walletOwner"));
        vm.label(walletOwner, "walletOwner");

        deployer = address(bytes20("deployer"));
        vm.label(deployer, "Deployer");
        vm.deal(deployer, DEPLOYER_INIT_ETH_AMOUNT);
        
        vm.startPrank(deployer);
        safuwalletlibray = IsafuWalletLibrary(
            payable(
                deployCode(
                    "./src/safu-wallet/SafuWalletLibrary.json"
                )
            )
        );
        vm.label(address(safuwalletlibray), "SafuWalletLibrary");

        address[] memory owners = new address[](1);
        owners[0] = walletOwner; // msg.sender is automatically considered an owner
        safuwallet = new SafuWallet(
            owners, 
            2, // both admins required to execute transactions
            type(uint256).max // max daily limit
        );

        // admin deposits 100 ETH to the wallet
        address(safuwallet).call{value: 100 ether}("");

        // admin withdraws 50 ETH from the wallet
        bytes memory executeData = abi.encodeWithSignature("execute(address,uint256,bytes)", deployer, 50 ether, "");
        address(safuwallet).call(executeData);
        vm.stopPrank();

        assertEq(address(safuwallet).balance, 50 ether);
    }

    function testExploit() public {
        vm.startPrank(attacker);
        //complete the challenge!

        vm.stopPrank();
        verify();
    }

    function verify() internal {
        /******************************************
        *                 INFO                    *
        *    Verify completion of the challenge   *
        *******************************************/
    vm.startPrank(deployer);
    bytes memory executeData = abi.encodeWithSignature("execute(address,uint256,bytes)", deployer, 50 ether, "");
    vm.expectRevert();
    (bool status, ) = address(safuwallet).call(executeData);
    assertTrue(status, "expectRevert: call did not revert");
    vm.stopPrank();
    }
}
