pragma solidity ^0.5.0;
import "./deployminer.sol";
import "./minerhelper.sol";

contract MinerGame is DeployMiner, MinerHelper {
    constructor() public payable {}
}