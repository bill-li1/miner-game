pragma solidity ^0.5.0;
import "./minerpool.sol";
import "./poolwinning.sol";
/**
* @title DeployMiner
* @dev deploying and undeploying miners in a pool
*/
contract DeployMiner is MinerPool, PoolWinning {

    // deploys a miner to specified pool
    function _deployMiner(string memory minername, string memory poolName) public payable
    isOwnerOfUser(minerToUser[getMinerId(minername)]) isOwnerOfMiner(getMinerId(minername), minerToUser[getMinerId(minername)]) {
        uint minerId = getMinerId(minername);
        uint userId = minerToUser[minerId];
        uint minerIndex = minerIdToMinerIndex[minerId];
        uint deployCost = 4828148648086300 + (100000000000 * users[userId].userMiners[minerIndex].diskSpace);
        require (msg.value == deployCost, "Requires 4828148648086300 + (100000000000 * your miner's diskspace) Wei.");
        require (users[userId].userMiners[minerIndex].available, "Miner is currently in a pool!");
        if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("smallPool")) &&
        !isFull(smallPool) &&
        users[userId].minersInSmallPool <= 20) {
            smallPool.poolMiners[smallPool.poolMinersCount] = users[userId].userMiners[minerIndex];
            users[userId].userMiners[minerIndex].available = false;
            users[userId].minersInSmallPool++;
            smallPool.money += deployCost;
            smallPool.poolMinersCount++;
            if (isFull(smallPool)) {
                _checkPool(100);
            }
        } else if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("medPool")) &&
        !isFull(medPool) &&
        users[userId].minersInMedPool <= 50) {
            medPool.poolMiners[medPool.poolMinersCount] = users[userId].userMiners[minerIndex];
            users[userId].userMiners[minerIndex].available = false;
            users[userId].minersInMedPool++;
            medPool.money += deployCost;
            medPool.poolMinersCount++;
            if (isFull(medPool)) {
                _checkPool(250);
            }
        } else if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("largePool")) &&
        !isFull(largePool) &&
        users[userId].minersInLargePool <= 200) {
            largePool.poolMiners[largePool.poolMinersCount] = users[userId].userMiners[minerIndex];
            users[userId].userMiners[minerIndex].available = false;
            users[userId].minersInLargePool++;
            largePool.money += deployCost;
            largePool.poolMinersCount++;
            if (isFull(largePool)) {
                _checkPool(1000);
            }
        }
    }

    // resets a deployed miner
    function resetDeployedMiner(string calldata minername, string calldata poolName) external
    isOwnerOfMiner(minerNameToMinerId[minername], minerToUser[minerNameToMinerId[minername]]) {
        uint minerId = getMinerId(minername);
        bool flag = false;
        if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("smallPool"))) {
            for (uint i = 0; i < smallPool.poolMinersCount; i++) {
                if (keccak256(abi.encodePacked(smallPool.poolMiners[i].minerName)) == keccak256(abi.encodePacked(minername))) {
                    flag = true;
                    break;
                }
            }
        }
        else if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("medPool"))) {
            for (uint i = 0; i < medPool.poolMinersCount; i++) {
                if (keccak256(abi.encodePacked(medPool.poolMiners[i].minerName)) == keccak256(abi.encodePacked(minername))) {
                    flag = true;
                    break;
                }
            }
        }
        else if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("largePool"))) {
            for (uint i = 0; i < largePool.poolMinersCount; i++) {
                if (keccak256(abi.encodePacked(largePool.poolMiners[i].minerName)) == keccak256(abi.encodePacked(minername))) {
                    flag = true;
                    break;
                }
            }
        }
        if (!flag) revert("Miner is not in the pool!");
        uint userId = minerToUser[minerId];
        uint minerIndex = minerIdToMinerIndex[minerId];
        users[userId].userMiners[minerIndex].available = true;
        if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("smallPool"))) {
            for (uint i = 0; i < smallPool.capacity; i++) {
                if (keccak256(abi.encodePacked(smallPool.poolMiners[i].minerName)) == keccak256(abi.encodePacked(minername)))
                delete(smallPool.poolMiners[i]);
            }
            users[userId].minersInSmallPool--;
            smallPool.poolMinersCount--;
        } else if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("medPool"))) {
            for (uint i = 0; i < medPool.capacity; i++) {
                if (keccak256(abi.encodePacked(medPool.poolMiners[i].minerName)) == keccak256(abi.encodePacked(minername)))
                delete(medPool.poolMiners[i]);
            }
            users[userId].minersInMedPool--;
            medPool.poolMinersCount--;
        } else if (keccak256(abi.encodePacked(poolName)) == keccak256(abi.encodePacked("largePool"))) {
            for (uint i = 0; i < largePool.capacity; i++) {
                if (keccak256(abi.encodePacked(largePool.poolMiners[i].minerName)) == keccak256(abi.encodePacked(minername)))
                delete(largePool.poolMiners[i]);
            }
             users[userId].minersInLargePool--;
             largePool.poolMinersCount--;
        }
    }
}