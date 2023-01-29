//SPDX-License-Identifier UNLICENSED

pragma solidity ^0.8.11;

interface IsafuWalletLibrary {
    function isOwner(address _addr) external view returns (bool);

    function m_numOwners() external view returns (uint256);

    function m_lastDay() external view returns (uint256);

    function m_spentToday() external view returns (uint256);

    function m_required() external view returns (uint256);

    function confirm(bytes32 _h) external returns (bool o_success);

    function initDaylimit(uint256 _limit) external;

    function execute(
        address _to,
        uint256 _value,
        bytes memory _data
    ) external returns (bytes32 o_hash);

    function revoke(bytes32 _operation) external;

    function hasConfirmed(bytes32 _operation, address _owner)
        external
        view
        returns (bool);

    function getOwner(uint256 ownerIndex) external view returns (address);

    function initMultiowned(address[] memory _owners, uint256 _required)
        external;

    function kill(address _to) external;

    function initWallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) external;

    function m_dailyLimit() external view returns (uint256);

    fallback() external payable;

    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event Deposit(address _from, uint256 value);
    event SingleTransact(
        address owner,
        uint256 value,
        address to,
        bytes data,
        address created
    );
    event MultiTransact(
        address owner,
        bytes32 operation,
        uint256 value,
        address to,
        bytes data,
        address created
    );
    event ConfirmationNeeded(
        bytes32 operation,
        address initiator,
        uint256 value,
        address to,
        bytes data
    );
}