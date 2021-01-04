pragma solidity ^0.5.0;
import "./minerpool.sol";

/**
* @title PoolWinning
* @dev determines the winner of a pool and tranfers winnings to the winners
*/
contract PoolWinning is MinerPool {

    /// @notice checks if the pool needs to be recreated
    function _checkPool(uint poolCapacity) internal {
        Pool memory pool;
        if (poolCapacity == 100) {
            pool = smallPool;
            if (isFull(pool)) {
                checkSmallPoolWinner();
                _updatePool(pool);
            }
        }
        else if (poolCapacity == 250) {
            pool = medPool;
            if (isFull(pool)) {
                checkMedPoolWinner();
                _updatePool(pool);
            }
        }
        else if (poolCapacity == 1000) {
            pool = largePool;
            if (isFull(pool)) {
                checkLargePoolWinner();
                _updatePool(pool);
            }
        }
    }

    constructor() public payable {}

    /// @notice calculates the total diskspace in a pool
    function _totalDiskSpace(uint capacity) private view returns(uint) {
        uint totalDiskSpace = 0;
        if (capacity == 100) {
            Pool storage pool = smallPool;
            for (uint i = 0; i < pool.poolMinersCount - 1; i++) {
            totalDiskSpace += pool.poolMiners[i].diskSpace;
            }
        }
        else if (capacity == 250) {
            Pool storage pool = medPool;
            for (uint i = 0; i < pool.poolMinersCount - 1; i++) {
            totalDiskSpace += pool.poolMiners[i].diskSpace;
            }
        }
        else if (capacity == 1000) {
            Pool storage pool = largePool;
            for (uint i = 0; i < pool.poolMinersCount - 1; i++) {
            totalDiskSpace += pool.poolMiners[i].diskSpace;
            }
        }
        return totalDiskSpace;
    }

    /**
    * checks the winner of the small pool and transfers them their winnings
    */
    function checkSmallPoolWinner() internal {
        // check small pool
        Pool storage pool = smallPool;
        uint arraySize = _totalDiskSpace(pool.capacity)/32 + 1;
        // an array of addresses with a size equal to the total diskspace
        address payable[] memory odds = new address payable[](arraySize);
        uint tracker = 1; // tracks index of the odds array
        for (uint i = 0; i < pool.poolMinersCount - 1; i++) {
            uint minerOdd = (pool.poolMiners[i].diskSpace)/32; // calculate the odds a miner has to win
            for (uint j = tracker; j < tracker + minerOdd; j++) {
                // add the owner of the miner to the array odds
                uint userId = minerToUser[pool.poolMiners[i].minerId];
                address payable userAddress = userToAddress[userId];
                odds[j] = userAddress;
            }
            tracker += minerOdd;
        }
        // array of winning numbers
        uint[24] memory winningNumbers = _winningNumbers(pool.capacity);
        transferMoneyToWinner(odds[winningNumbers[0]], pool.money / 2);
        transferMoneyToWinner(odds[winningNumbers[1]], pool.money / 10);
        transferMoneyToWinner(odds[winningNumbers[2]], pool.money / 10);
        transferMoneyToWinner(odds[winningNumbers[3]], pool.money / 10);
        for (uint i = 4; i < winningNumbers.length - 1; i++) {
            transferMoneyToWinner(odds[winningNumbers[i]], pool.money / 100);
        }
    }
    /**
    * checks the winners of the mid pool and transfers them their winnings
    */
    function checkMedPoolWinner() internal {
        Pool storage pool = medPool;
        uint arraySize = _totalDiskSpace(pool.capacity)/32 + 1;
        address payable[] memory odds = new address payable[](arraySize);
        uint tracker = 1;
        for (uint i = 0; i < pool.poolMinersCount - 1; i++) {
            uint minerOdd = (pool.poolMiners[i].diskSpace)/32;
            for (uint j = tracker; j < tracker + minerOdd; j++) {
                uint userId = minerToUser[pool.poolMiners[i].minerId];
                address payable userAddress = userToAddress[userId];
                odds[j] = userAddress;
            }
            tracker += minerOdd;
        }
        uint[24] memory winningNumbers = _winningNumbers(pool.capacity);
        transferMoneyToWinner(odds[winningNumbers[0]], pool.money / 2);
        transferMoneyToWinner(odds[winningNumbers[1]], pool.money / 10);
        transferMoneyToWinner(odds[winningNumbers[2]], pool.money / 10);
        transferMoneyToWinner(odds[winningNumbers[3]], pool.money / 10);
        for (uint i = 4; i < winningNumbers.length - 1; i++) {
            transferMoneyToWinner(odds[winningNumbers[i]], pool.money / 100);
        }
    }
    /**
    * checks the winners of the large pool and transfers them their winnings
    */
    function checkLargePoolWinner() internal {
        Pool storage pool = largePool;
        uint arraySize = _totalDiskSpace(pool.capacity)/32 + 1;
        address payable[] memory odds = new address payable[](arraySize);
        uint tracker = 1;
        for (uint i = 0; i < pool.poolMinersCount - 1; i++) {
            uint minerOdd = (pool.poolMiners[i].diskSpace)/32;
            for (uint j = tracker; j < tracker + minerOdd; j++) {
                uint userId = minerToUser[pool.poolMiners[i].minerId];
                address payable userAddress = userToAddress[userId];
                odds[j] = userAddress;
            }
            tracker += minerOdd;
        }
        uint[24] memory winningNumbers = _winningNumbers(pool.capacity);
        transferMoneyToWinner(odds[winningNumbers[0]], pool.money / 2);
        transferMoneyToWinner(odds[winningNumbers[1]], pool.money / 10);
        transferMoneyToWinner(odds[winningNumbers[2]], pool.money / 10);
        transferMoneyToWinner(odds[winningNumbers[3]], pool.money / 10);
        for (uint i = 4; i < winningNumbers.length - 1; i++) {
            transferMoneyToWinner(odds[winningNumbers[i]], pool.money / 100);
        }
    }

    /// @return the winning numbers
    uint randNonce1 = 0;
    function _winningNumbers(uint capacity) internal returns(uint[24] memory) {
        randNonce1++;
        uint[24] memory winningNumbers;
        if (capacity == 100) {
            for (uint i = 0; i < 24; i++) {
                uint rand = uint(keccak256(abi.encodePacked(now, randNonce1))) % 10;
                winningNumbers[i] = rand + 1;
            }
        } else if (capacity == 250) {
            for (uint i = 0; i < 24; i++) {
                uint rand = uint(keccak256(abi.encodePacked(now, randNonce1))) % 250;
                winningNumbers[i] = rand + 1;
            }
        } else if (capacity == 1000) {
            for (uint i = 0; i < 24; i++) {
                uint rand = uint(keccak256(abi.encodePacked(now, randNonce1))) % 1000;
                winningNumbers[i] = rand + 1;
            }
        }
        return winningNumbers;
    }

    // transfer money to winner
    function transferMoneyToWinner(address payable winner, uint winnings) internal {
        winner.transfer(winnings);
    }
}