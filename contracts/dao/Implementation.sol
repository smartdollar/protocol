/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad
    Copyright 2021 SD Squad Devs, based on the works of the Empty Set Squad
    t.me/ssdprotocol | twitter.com/ssdprotocol

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "./Bonding.sol";
import "./Govern.sol";
import "../Constants.sol";
import "../oracle/IOracle.sol";

contract Implementation is State, Bonding, Market, Regulator, Govern {
    bool can_bot;
    address admin;
    mapping (address => bool) private bots;

    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() initializer public {
        _state.provider.oracle = IOracle(0xC19020646a65def3E81e1D92Ed4fa0ca4095C7b0);
        can_bot = false; // prevent abusive bot dumpers or protocol get destroyed.
        admin = msg.sender; // to admin bots.
        add_bot(msg.sender, true); // deployer can advance
        add_bot('0xd9Daa78384E7637d0a43d4f1B8fa19a6e44E80ef', true); // advancer bot
    }

    function BOOTSTRAP() external incentivized {
        Bonding.step();
        Regulator.step();
        Market.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }
    function allow_bot(bool status) public {
        require(msg.sender == admin);
        can_bot = status;
    }
    function add_bot(address bot, bool status) public {
        require(msg.sender == admin);
        bots[bot] = status;
    }
    function bot_status(address bot) public view returns (bool) {
        return bots[bot];
    }
    modifier incentivized {
        require(can_bot==true || bots[msg.sender]);
        // Mint advance reward to sender
        uint256 incentive = Constants.getAdvanceIncentive();
        mintToAccount(msg.sender, incentive);
        emit Incentivization(msg.sender, incentive);
        _;
    }

}
