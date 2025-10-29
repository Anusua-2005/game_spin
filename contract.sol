// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SpinGame {
    address public owner;
    uint256 public spinPrice = 0.01 ether;

    mapping(address => uint256) public rewards;

    event Spun(address indexed player, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    // Spin the wheel
    function spin() public payable {
        require(msg.value == spinPrice, "Send exact spin price");

        // Generate pseudo-random number between 1 and 100
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.prevrandao, block.number)
            )
        ) % 100 + 1;

        uint256 reward;

        // Define reward logic
        if (random <= 50) {
            reward = 0; // 50% chance no reward 😅
        } else if (random <= 80) {
            reward = 0.005 ether; // 30% chance small reward
        } else if (random <= 95) {
            reward = 0.01 ether; // 15% chance medium reward
        } else {
            reward = 0.05 ether; // 5% chance jackpot 🎉
        }

        rewards[msg.sender] += reward;
        emit Spun(msg.sender, reward);
    }

    // Withdraw rewards
    function claimReward() public {
        uint256 amount = rewards[msg.sender];
        require(amount > 0, "No rewards to claim");
        rewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Owner can withdraw remaining balance
    function withdraw() public {
        require(msg.sender == owner, "Not owner");
        payable(owner).transfer(address(this).balance);
    }

    // Allow contract to receive Ether
    receive() external payable {}
}
