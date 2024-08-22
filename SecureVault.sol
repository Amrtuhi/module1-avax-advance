// Vault.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./GameToken.sol";

contract SecureVault {
    GameToken public immutable token;

    struct Gamer {
        uint tokenBalance;
        uint expPoints;
        uint achievementCount;
        uint battlesWon;
        uint explorations;
        bool hasVotingRights;
        uint playerLevel;
        string playerName;
    }

    uint public totalTokens;
    mapping(address => Gamer) public gamers;
    address[] public gamerAddresses;
    uint private gamerIndex;

    constructor(address _tokenAddress) {
        token = GameToken(_tokenAddress);
    }

    function _createTokens(address _to, uint _quantity) private {
        totalTokens += _quantity;
        gamers[_to].tokenBalance += _quantity;
    }

    function _destroyTokens(address _from, uint _quantity) private {
        totalTokens -= _quantity;
        gamers[_from].tokenBalance -= _quantity;
    }

    function addTokens(uint _amount) external {
        uint newTokens;
        if (totalTokens == 0) {
            newTokens = _amount;
        } else {
            newTokens = (_amount * totalTokens) / token.balanceOf(address(this));
        }

        _createTokens(msg.sender, newTokens);
        token.transferFrom(msg.sender, address(this), _amount);
        refreshLeaderboard();
    }

    function removeTokens(uint _amount) external {
        uint withdrawAmount = (_amount * token.balanceOf(address(this))) / totalTokens;
        _destroyTokens(msg.sender, _amount);
        token.transfer(msg.sender, withdrawAmount);
        refreshLeaderboard();
    }

    function addPlayer(string memory _name, uint _level, uint _startTokens) external {
        gamerIndex++;
        address gamerAddress = address(uint160(gamerIndex));
        
        gamers[gamerAddress] = Gamer(_startTokens, 0, 0, 0, 0, false, _level, _name);
        gamerAddresses.push(gamerAddress);

        // Simulate initial battles and explorations for the gamer
        simulateBattles(gamerAddress, 0); // Simulate 0 battle wins
        simulateExplorations(gamerAddress, 0); // Simulate exploring 0 times

        refreshLeaderboard();
    }

    function engageBattle(address _opponent) external {
        require(gamers[msg.sender].tokenBalance > 0, "Insufficient balance");
        require(gamers[_opponent].tokenBalance > 0, "Opponent has insufficient balance");

        bool win = (block.timestamp % 2 == 0); // Simple condition for win
        if (win) {
            gamers[_opponent].battlesWon++;
            gamers[_opponent].expPoints += 10;
        }
        if (gamers[_opponent].expPoints >= 10) {
            gamers[_opponent].hasVotingRights = true;
        }

        // Update leaderboard after the battle
        refreshLeaderboard();
    }

    function embarkExplore() external {
        require(gamers[msg.sender].tokenBalance > 0, "Insufficient balance");
        uint rewardTokens = 50; // Reward for exploration
        gamers[msg.sender].explorations++;
        gamers[msg.sender].tokenBalance += rewardTokens; // Update token balance directly
        refreshLeaderboard();
    }

    function buyItem(uint _cost) external {
        require(gamers[msg.sender].tokenBalance >= _cost, "Insufficient balance");
        gamers[msg.sender].tokenBalance -= _cost; // Deduct tokens directly
        // Logic for buying items goes here
    }

    function transferTokens(address _to, uint _quantity) external {
        require(gamers[msg.sender].tokenBalance >= _quantity, "Insufficient balance");
        gamers[msg.sender].tokenBalance -= _quantity;
        gamers[_to].tokenBalance += _quantity;
    }

    function getLeaderboard() external view returns (address[] memory) {
        address[] memory sortedAddresses = new address[](gamerAddresses.length);
        for (uint i = 0; i < gamerAddresses.length; i++) {
            sortedAddresses[i] = gamerAddresses[i];
        }

        // Sort leaderboard by token balance (descending), and if tied, by battle wins
        for (uint i = 0; i < sortedAddresses.length; i++) {
            for (uint j = i + 1; j < sortedAddresses.length; j++) {
                address gamerA = sortedAddresses[i];
                address gamerB = sortedAddresses[j];
                if (gamers[gamerA].tokenBalance < gamers[gamerB].tokenBalance ||
                    (gamers[gamerA].tokenBalance == gamers[gamerB].tokenBalance &&
                    gamers[gamerA].battlesWon < gamers[gamerB].battlesWon)) {
                    address temp = sortedAddresses[i];
                    sortedAddresses[i] = sortedAddresses[j];
                    sortedAddresses[j] = temp;
                }
            }
        }
        return sortedAddresses;
    }

    function getGamer(address _gamer) external view returns (Gamer memory) {
        return gamers[_gamer];
    }

    function removeGamerData(address gamerAddress) private {
        delete gamers[gamerAddress];
        // Remove gamer address from gamerAddresses array
        for (uint i = 0; i < gamerAddresses.length; i++) {
            if (gamerAddresses[i] == gamerAddress) {
                gamerAddresses[i] = gamerAddresses[gamerAddresses.length - 1];
                gamerAddresses.pop();
                break;
            }
        }
    }

    function simulateBattles(address gamerAddress, uint count) private {
        for (uint i = 0; i < count; i++) {
            gamers[gamerAddress].battlesWon++;
            gamers[gamerAddress].expPoints += 10;
        }
        refreshLeaderboard();
    }

    function simulateExplorations(address gamerAddress, uint count) private {
        for (uint i = 0; i < count; i++) {
            gamers[gamerAddress].explorations++;
            uint rewardTokens = 50; // Fixed reward
            gamers[gamerAddress].tokenBalance += rewardTokens;
        }
        refreshLeaderboard();
    }

    function refreshLeaderboard() private {
        // Bubble sort to maintain the leaderboard order
        for (uint i = 0; i < gamerAddresses.length; i++) {
            for (uint j = i + 1; j < gamerAddresses.length; j++) {
                if (gamers[gamerAddresses[i]].tokenBalance < gamers[gamerAddresses[j]].tokenBalance ||
                    (gamers[gamerAddresses[i]].tokenBalance == gamers[gamerAddresses[j]].tokenBalance &&
                    gamers[gamerAddresses[i]].battlesWon < gamers[gamerAddresses[j]].battlesWon)) {
                    address temp = gamerAddresses[i];
                    gamerAddresses[i] = gamerAddresses[j];
                    gamerAddresses[j] = temp;
                }
            }
        }
    }
}
