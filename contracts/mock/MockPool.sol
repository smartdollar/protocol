/*
    Copyright 2020 Dynamic Dollar Devs, based on the works of the Empty Set Squad

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

import "../oracle/Pool.sol";
import "../token/ISmarty.sol";
import "../oracle/IOracle.sol";
contract MockPool is Pool {
    address private _usdc;
    IDAO private _dao;
    ISmarty private _dollar;
    IERC20 private _univ2;
    IOracle private _oracle;

    function set(address usdc, address dao, address dollar,
                 address univ2, address oracle, address factory) external {
        _usdc = usdc;
        _dao = IDAO(dao);
        _dollar = ISmarty(dollar);
        _univ2 = IERC20(univ2);
        _oracle = IOracle(oracle);
        init(dollar,univ2, usdc, factory);
    }

    function usdc() public view returns (address) {
        return _usdc;
    }

    function dao() public view returns (IDAO) {
        return _dao;
    }

    function dollar() public view returns (ISmarty) {
        return _dollar;
    }

    function univ2() public view returns (IERC20) {
        return _univ2;
    }

    function getReserves(address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (reserveA, reserveB,) = IUniswapV2Pair(address(univ2())).getReserves();
    }

    function oracle() public view returns (IOracle) {
        return _oracle;
    }

}
