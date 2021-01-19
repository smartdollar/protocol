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

import "./external/Decimal.sol";

library Constants {
    /* Chain */
    uint256 private constant CHAIN_ID = 56; // bsc

    /* Bootstrapping */
    uint256 private constant BOOTSTRAPPING_PERIOD = 300; // 2 weeks
    uint256 private constant BOOTSTRAPPING_PRICE = 11e17; // 1.1 BUSD (targeting 0.75% inflation)

    /* Oracle */
    // BinanceUSD
    address private constant USDC = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    uint256 private constant ORACLE_RESERVE_MINIMUM = 1e10; // 10,000 USDC

    /* Bonding */
    uint256 private constant INITIAL_STAKE_MULTIPLE = 1e6; // 100 SD -> 100M SDS

    // bootstrap mint program
    address private constant TREASURE = address(0x3e1850AcA3680F207C477143dc6ac80A3390817E); // INDEX=0

    /* Epoch */
    struct EpochStrategy {
        uint256 offset;
        uint256 start;
        uint256 period;
    }

    uint256 private constant EPOCH_OFFSET = 0;
    uint256 private constant EPOCH_START = 1610501086;
    uint256 private constant EPOCH_PERIOD = 3600; // 1 hour

    /* Governance */
    uint256 private constant GOVERNANCE_PERIOD = 4; // hours
    uint256 private constant GOVERNANCE_QUORUM = 25e16; // 25%
    uint256 private constant GOVERNANCE_SUPER_MAJORITY = 51e16; // 51%
    uint256 private constant GOVERNANCE_EMERGENCY_DELAY = 2; // 1 epoch

    /* DAO */
    uint256 private constant ADVANCE_INCENTIVE = 50e18; // 50 SD
    uint256 private constant DAO_EXIT_LOCKUP_EPOCHS = 36; // 36 epochs fluid

    /* Pool */
    uint256 private constant POOL_EXIT_LOCKUP_EPOCHS = 12; // 12 epochs fluid

    /* Market */
    uint256 private constant COUPON_EXPIRATION = 1440; // 60 days
    uint256 private constant DEBT_RATIO_CAP = 35e16; // 35%
    uint256 private constant INITIAL_COUPON_REDEMPTION_PENALTY = 25e16; // 25%
    uint256 private constant COUPON_REDEMPTION_PENALTY_DECAY = 1200; // 20 minutes

    /* Regulator */
    uint256 private constant SUPPLY_CHANGE_DIVISOR = 12e18; // 12
    uint256 private constant SUPPLY_CHANGE_LIMIT = 1e16; // 1%
    uint256 private constant ORACLE_POOL_RATIO = 40; // 40%

    /**
     * Getters
     */
    function getTreasureAddress() internal pure returns (address) {
        return TREASURE;
    }

    function getUsdcAddress() internal pure returns (address) {
        return USDC;
    }

    function getOracleReserveMinimum() internal pure returns (uint256) {
        return ORACLE_RESERVE_MINIMUM;
    }

    function getEpochStrategy() internal pure returns (EpochStrategy memory) {
        return EpochStrategy({
            offset: EPOCH_OFFSET,
            start: EPOCH_START,
            period: EPOCH_PERIOD
        });
    }

    function getInitialStakeMultiple() internal pure returns (uint256) {
        return INITIAL_STAKE_MULTIPLE;
    }

    function getBootstrappingPeriod() internal pure returns (uint256) {
        return BOOTSTRAPPING_PERIOD;
    }

    function getBootstrappingPrice() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: BOOTSTRAPPING_PRICE});
    }

    function getGovernancePeriod() internal pure returns (uint256) {
        return GOVERNANCE_PERIOD;
    }

    function getGovernanceQuorum() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: GOVERNANCE_QUORUM});
    }

    function getGovernanceSuperMajority() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: GOVERNANCE_SUPER_MAJORITY});
    }

    function getGovernanceEmergencyDelay() internal pure returns (uint256) {
        return GOVERNANCE_EMERGENCY_DELAY;
    }

    function getAdvanceIncentive() internal pure returns (uint256) {
        return ADVANCE_INCENTIVE;
    }

    function getDAOExitLockupEpochs() internal pure returns (uint256) {
        return DAO_EXIT_LOCKUP_EPOCHS;
    }

    function getPoolExitLockupEpochs() internal pure returns (uint256) {
        return POOL_EXIT_LOCKUP_EPOCHS;
    }

    function getCouponExpiration() internal pure returns (uint256) {
        return COUPON_EXPIRATION;
    }

    function getDebtRatioCap() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: DEBT_RATIO_CAP});
    }
    
    function getInitialCouponRedemptionPenalty() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: INITIAL_COUPON_REDEMPTION_PENALTY});
    }

    function getCouponRedemptionPenaltyDecay() internal pure returns (uint256) {
        return COUPON_REDEMPTION_PENALTY_DECAY;
    }

    function getSupplyChangeLimit() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: SUPPLY_CHANGE_LIMIT});
    }

    function getSupplyChangeDivisor() internal pure returns (Decimal.D256 memory) {
        return Decimal.D256({value: SUPPLY_CHANGE_DIVISOR});
    }

    function getOraclePoolRatio() internal pure returns (uint256) {
        return ORACLE_POOL_RATIO;
    }

    function getChainId() internal pure returns (uint256) {
        return CHAIN_ID;
    }
}
