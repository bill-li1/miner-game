pragma solidity ^0.5.0;

/**
* @author mlin-dxchain, bli-dxchain
* @title the base of the virtualminer game
*/
contract VirtualMiner {

    address _owner;
    constructor() public payable {
        _owner = msg.sender;
    }

    struct Miner {
        uint32 diskSpace;
        uint minerId;
        string minerName;
        bool available;
    }
    struct User {
        address userAddress;
        string username;
        mapping (uint => Miner) userMiners;
        uint16 minerIndex;
        uint8 minersInSmallPool;
        uint8 minersInMedPool;
        uint16 minersInLargePool;
    }
    /**
    * @notice checks if they're the owner of the user
    * @dev require the userId to match the sender's address
    */
    modifier isOwnerOfUser(uint _userId) {
        require(userToAddress[_userId] == msg.sender, "You're not the user!");
        _;
    }

    /**
    * @notice checks if they own that miner
    */
    modifier isOwnerOfMiner(uint _minerId, uint _userId) {
        require(minerToUser[_minerId] == _userId, "You do not own this miner!");
        _;
    }

    /**
    * @dev checks if you are the owner
    */
    modifier onlyOwner() {
        require(msg.sender == _owner, "You are not the owner.");
        _;
    }

    /**
    * @notice the array storing all the users.
    * @dev users are identified by their index in this array.
    */
    User[] public users;
    string[] public minernames;
    mapping (uint => address payable) userToAddress;
    mapping (address => uint) addressToUser;
    mapping (uint => uint) minerToUser;
    mapping (uint => uint) minerIdToMinerIndex;
    mapping (string => uint) minerNameToMinerId;
    mapping(string => uint) userNameToUserId;
    /**
    * @notice creates a new user
    * @dev stores user id into mapping
    */
    function _createNewUser(string calldata _name) external {
        require(usernameAvailability(_name), "Name is unavailable. Please try another.");
        require(uniqueUser(msg.sender), "You already have an account!");
        address payable userAddress = msg.sender;
        uint id = users.push(User(msg.sender, _name, 0, 0, 0, 0)) - 1;
        userToAddress[id] = userAddress;
        addressToUser[userAddress] = id;
        userNameToUserId[_name] = id;
    }
    uint minerCost = 9656297296172600;
    uint upgradeCost = 10000000000000;
    // creates a new miner
    function _createNewMiner(string memory _minerName) internal {
        require(minernameAvailability(_minerName), "Name is unavailable. Please try another.");
        uint userId = addressToUser[msg.sender];
        uint minerId = _minerIdGeneration(_minerName);
        minerToUser[minerId] = userId;
        minerIdToMinerIndex[minerId] = users[userId].minerIndex;
        minerNameToMinerId[_minerName] = minerId;
        minernames.push(_minerName);
        users[userId].userMiners[users[userId].minerIndex] = Miner(32, minerId, _minerName, true);
        users[userId].minerIndex++;
    }
    /**
    * @param _minerName the name of the miner
    * @notice purchases new miner
    */
    function _purchaseMiner(string memory _minerName) public payable {
        require(msg.value == minerCost, "Required amount is 9656297296172600 Wei");
        _createNewMiner(_minerName);
    }

    /// @notice upgrades a miner
    function _upgradeMiner(string calldata _username, string calldata _minername) external payable
    isOwnerOfUser(userNameToUserId[_username])
    isOwnerOfMiner(minerNameToMinerId[_minername], userNameToUserId[_username]) {
        require(msg.value == upgradeCost, "Required amount is 10000000000000 Wei");
        uint userId = userNameToUserId[_username];
        uint minerId = minerNameToMinerId[_minername];
        uint minerIndex = minerIdToMinerIndex[minerId];
        require(users[userId].userMiners[minerIndex].diskSpace <= 1000000, "Your miner is fully upgraded!");
        users[userId].userMiners[minerIndex].diskSpace += 32;
    }

    /// @notice creates a random minerId
    uint randNonce = 0;
    function _minerIdGeneration(string memory _minerName) private returns(uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(now, randNonce, _minerName))) % (10 ** 16);
    }

    /// @return minerId from minerName
    function getMinerId(string memory _minerName) public view returns (uint minerId) {
        minerId = minerNameToMinerId[_minerName];
    }

    /// @return minerDiskSpace
    function getMinerDiskspace(string memory _minerName) public view returns (uint minerDiskSpace) {
        uint minerId = getMinerId(_minerName);
        uint userId = minerToUser[minerId];
        uint minerIndex = minerIdToMinerIndex[minerId];
        minerDiskSpace = users[userId].userMiners[minerIndex].diskSpace;
    }

    /// @return deploy cost of miner
    function getMinerDeployCost(string calldata _minerName) external view returns (uint deployCost) {
        uint minerId = getMinerId(_minerName);
        uint userId = minerToUser[minerId];
        uint minerIndex = minerIdToMinerIndex[minerId];
        deployCost = 4828148648086300 + (100000000000 * users[userId].userMiners[minerIndex].diskSpace);
    }

    /// @return true of minername is available
    function minernameAvailability(string memory minername) internal view returns (bool) {
        for (uint i = 0; i < minernames.length; i++) {
            if (keccak256(abi.encodePacked(minername)) == keccak256(abi.encodePacked(minernames[i]))) {
                return false;
            }
        }
        return true;
    }

    /// @return true of username is available
    function usernameAvailability(string memory username) internal view returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            uint userId = userNameToUserId[username];
            if (keccak256(abi.encodePacked(users[userId].username)) == keccak256(abi.encodePacked(username))) {
                return false;
            }
        }
        return true;
    }

    /// @return true if there is no account linked to that address
    function uniqueUser(address userAddress) internal view returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (userAddress == users[i].userAddress) {
                return false;
            }
        }
        return true;
    }

}