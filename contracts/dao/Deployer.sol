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
import "../token/Dollar.sol";
import "../oracle/Oracle.sol";
import "../oracle/Pool.sol";
import "./Upgradeable.sol";
import "./Permission.sol";


contract Deployer1 is State, Permission, Upgradeable {
    function initialize() initializer public {
        _state.provider.dollar = new Dollar();
    }

    function implement(address implementation) external {
        upgradeTo(implementation);
    }
    function dollar() public view returns (IDollar) {
        return _state.provider.dollar;
    }
}

contract Deployer2 is State, Permission, Upgradeable {
    function initialize() initializer public {
        //_state.provider.oracle = new Oracle(address(dollar()));
        //oracle().setup();
    }

    function implement(address implementation) external {
        upgradeTo(implementation);
    }
    function oracle() public view returns (IOracle) {
        return _state.provider.oracle;
    }
}

contract Deployer3 is State, Permission, Upgradeable {
    function initialize() initializer public {
        _state.provider.pool = address(new Pool(address(dollar()), address(oracle().pair())));
    }

    function implement(address implementation) external {
        upgradeTo(implementation);
    }
    function pool() public view returns (address) {
        return _state.provider.pool;
    }
    function pair() public view returns (address) {
        return oracle().pair();
    }
}

contract Deployer4 is State, Permission, Upgradeable {
    function initialize() initializer public {
        _state.provider.oracle = new Oracle();
    }

    function implement(address implementation) external {
        upgradeTo(implementation);
    }
    function oracle() public view returns (IOracle) {
        return _state.provider.oracle;
    }
}