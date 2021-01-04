pragma solidity ^0.5.0;
import "./miner.sol";
/**
* @title MinerHelper
* @dev retrieves miner information of a user
*/
contract MinerHelper is VirtualMiner {

    /// @return all the miners a user owns
    function displayMinersOfUser(string calldata _username) external view returns (uint[] memory) {
        uint userId = userNameToUserId[_username];
        uint[] memory result = new uint[](users[userId].minerIndex);
        for (uint i = 0; i < users[userId].minerIndex; i++) {
                result[i] = users[userId].userMiners[i].minerId;
        }
        return result;
    }

    /// @return all available miners a user owns
    function displayAvailableMiners(string calldata _username) external view returns (uint[] memory) {
        uint userId = userNameToUserId[_username];
        uint[] memory result = new uint[](users[userId].minerIndex);
        for (uint i = 0; i < users[userId].minerIndex; i++) {
            if (users[userId].userMiners[i].available) {
                result[i] = users[userId].userMiners[i].minerId;
            }
            else {
                result[i] = 0;
            }
        }
        return result;
    }

}