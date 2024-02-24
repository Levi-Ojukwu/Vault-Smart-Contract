// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Vault {
    
    struct Grant {
        uint256 amount;
        uint256 releaseTime;
        address beneficiary;
    }


    mapping(address => Grant) public grants;

    event GrantCreatedSuccessful(address indexed _donor, address indexed _beneficiary, uint256 _amount, uint256 _releaseTime);
    event FundsClaimedSuccessful(address indexed _beneficiary, uint256 _amount);

    function createGrant(address _beneficiary, uint256 _releaseTime) external payable {
        require(msg.value > 0, "Deposit must be greater that Zero.");
        require(_beneficiary != address(0), "Beneficiary cannot be zero address.");
        require(_releaseTime > block.timestamp, "Relase Time must be in the future");
        require(grants[msg.sender].amount == 0, "Grant already exist");

        grants[msg.sender] = Grant({
            amount: msg.value,
            releaseTime: _releaseTime,
            beneficiary: _beneficiary
        });

        emit GrantCreatedSuccessful(msg.sender, _beneficiary, msg.value, _releaseTime);
    }

    function claimFunds() external {
        Grant storage grant = grants[msg.sender];

        require(block.timestamp >= grant.releaseTime, "Cannot recieve grant at this current time.");
        require(grant.amount > 0, "No funds to claim.");

        uint256 amount = grant.amount;
        grant.amount = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether.");

        emit FundsClaimedSuccessful(msg.sender, amount);
    }

    function viewGrant(address _donor) external view returns(Grant memory) {
        return grants[_donor];
    }
}
