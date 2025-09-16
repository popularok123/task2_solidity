// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BeggingContract {
    mapping(address => uint256) public donateAmount;
    address public owner;

    event Donation(address indexed funder, uint256 amount);

    uint256 public startTime;
    uint256 public endTime;

    address[] private donors;

    constructor(uint256 _startTime, uint256 _endTime) {
        require(_endTime > _startTime, "End time must be greater than start time");
        owner = msg.sender;
        startTime = _startTime;
        endTime = _endTime;
    }

    function donate() external payable {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Donations not allowed now");
        require(msg.value > 0, "Donation must be greater than 0");

        if (donateAmount[msg.sender] == 0) {
            donors.push(msg.sender);
        }
        donateAmount[msg.sender] += msg.value;
        emit Donation(msg.sender, msg.value);
    }

    function getTopDonors() external view returns (address[3] memory, uint256[3] memory) {
        address[3] memory topAddrs;
        uint256[3] memory topAmounts;

        for (uint256 i = 0; i < donors.length; i++) {
            uint256 amount = donateAmount[donors[i]];
            for (uint256 j = 0; j < 3; j++) {
                if (amount > topAmounts[j]) {
                    for (uint256 k = 2; k > j; k--) {
                        topAmounts[k] = topAmounts[k - 1];
                        topAddrs[k] = topAddrs[k - 1];
                    }
                    topAmounts[j] = amount;
                    topAddrs[j] = donors[i];
                    break;
                }
            }
        }
        return (topAddrs, topAmounts);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");

        payable(owner).transfer(balance);
    }

    function getDonation(address funder) public view returns (uint256) {
        return donateAmount[funder];
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "this function can only be called by owner");
        _;
    }
}
