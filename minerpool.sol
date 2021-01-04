pragma solidity ^0.5.0;

import "./miner.sol";

/**
* @title MinerPool
* @dev code for miner pools for virtualminer
* @author mlin-dxchain
*/
contract MinerPool is VirtualMiner {
    struct Pool {
        uint16 capacity;
        mapping (uint => Miner) poolMiners;
        uint money;
        uint16 poolMinersCount;
    }
    Pool public smallPool = Pool(100, 0, 0);
    Pool public medPool = Pool(250, 0, 0);
    Pool public largePool = Pool(1000, 0, 0);

    /**
    * @param _pool the pool you want to check
    * @return true if full
    */
    function isFull(Pool memory _pool) internal pure returns (bool) {
        if (_pool.poolMinersCount == _pool.capacity) {
            return true;
        } else {
            return false;
        }
    }

    /// @notice updates the pool
    function _updatePool(Pool memory _pool) internal {
        _createNewPool(_pool.capacity);
    }

    /// @return a new small pool
    function _createNewPool(uint poolcapacity) internal {
        if (poolcapacity == 100) { // create a new smallpool
            for (uint i = 0; i < poolcapacity; i++) {
                uint minerId = smallPool.poolMiners[i].minerId;
                uint userId = minerToUser[minerId];
                uint minerIndex = minerIdToMinerIndex[minerId];
                users[userId].userMiners[minerIndex].available = true;
                users[userId].minersInSmallPool--;
            }
            delete(smallPool);
            smallPool = Pool(100, 0, 0);
        }
        else if (poolcapacity == 250) { // create a new medpool
            for (uint i = 0; i < poolcapacity; i++) {
                uint userId = minerToUser[medPool.poolMiners[i].minerId];
                uint minerIndex = minerIdToMinerIndex[medPool.poolMiners[i].minerId];
                users[userId].userMiners[minerIndex].available = true;
                users[userId].minersInMedPool--;
            }
            delete(medPool);
            medPool = Pool(250, 0, 0);
        }
        else if (poolcapacity == 1000) { // create a new largepool
            for (uint i = 0; i < poolcapacity; i++) {
                uint userId = minerToUser[largePool.poolMiners[i].minerId];
                uint minerIndex = minerIdToMinerIndex[largePool.poolMiners[i].minerId];
                users[userId].userMiners[minerIndex].available = true;
                users[userId].minersInLargePool--;
            }
            delete(largePool);
            largePool = Pool(1000, 0, 0);
        }
    }

}
