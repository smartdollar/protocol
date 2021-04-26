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

import "../external/Decimal.sol";
import "../token/Smarty.sol";
import "../oracle/Oracle.sol";
import "../oracle/Pool.sol";
import "./Upgradeable.sol";
import "./Permission.sol";


contract Deployer is State, Permission, Upgradeable {
    function initialize() initializer public {

    }
    function implement(address implementation) external {
        upgradeTo(implementation);
    }
    function setup( address _SMARTY,
                    address _ORACLE,
                    address _CURRENCY,
                    address _FACTORY,
                    address _POOL ) public {
        _state.provider.dollar = Smarty(_SMARTY);
        _state.provider.CURRENCY = _CURRENCY;
        _state.provider.FACTORY = _FACTORY;
        _state.provider.oracle = Oracle(_ORACLE);
        _state.provider.pool = _POOL;
    }
}
