const { accounts, contract } = require('@openzeppelin/test-environment');

const { BN, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const MockPool = contract.fromArtifact('MockPool');
const MockToken = contract.fromArtifact('MockToken');
const MockUniswapV2PairLiquidity = contract.fromArtifact('MockUniswapV2PairLiquidity');
const MockSettableDAO = contract.fromArtifact('MockSettableDAO');

const Dollar = contract.fromArtifact('Dollar');
const MockSettableOracle = contract.fromArtifact('MockSettableOracle');

const INITIAL_STAKE_MULTIPLE = new BN(10).pow(new BN(6)); // 100 DSD -> 100M DSDS

const FROZEN = new BN(0);
const FLUID = new BN(1);


function cents(n) {
  return new BN(n).mul(new BN(10).pow(new BN(16)));
}
async function simulateTrade(amm, esd, usdc) {
  return await amm.simulateTrade(
      new BN(esd).mul(new BN(10).pow(new BN(18))),
      new BN(usdc).mul(new BN(10).pow(new BN(18))));
}
async function incrementEpoch(dao) {
  await dao.set((await dao.epoch()).toNumber() + 1);
}
async function priceForToBN(oracle) {
  return (await oracle.capture.call())[0].value;
}

function events(tx){
  if( ! tx || ! tx.receipt || !tx.receipt.logs ) return;
  const logs = tx.receipt.logs;
  for( let i in logs ){
    const r = logs[i];
    let args = [];
    //console.log(r.event, r.args);

    let s=0;
    const t = r.args.__length__;
    for( let j in r.args ){
      if(s>=t) break;
      let value = r.args[j];
      if( value == typeof BN )
        value = r.args[j].toString();
      args.push( r.args[j] );

      s++;
    }
    console.log( '*'+ r.event + '('+args.join(', ')+')' );
  }
}

describe('Pool', function () {
  const [ownerAddress, userAddress, userAddress1, userAddress2, mockDao] = accounts;

  beforeEach(async function () {
    this.dollar = await MockToken.new("Dynamic Set Dollar", "DSD", 18, {from: ownerAddress, gas: 8000000});
    this.pool = await MockPool.new(this.dollar.address, {from: ownerAddress, gas: 8000000});

    this.dao = await MockSettableDAO.new(this.pool.address, {from: ownerAddress, gas: 8000000});
    await this.dao.set(1);
    this.usdc = await MockToken.new("USD//C", "USDC", 18, {from: ownerAddress, gas: 8000000});
    this.univ2 = await MockUniswapV2PairLiquidity.new({from: ownerAddress, gas: 8000000});

    this.oracle = await MockSettableOracle.new({from: ownerAddress, gas: 8000000});


    await this.pool.set(this.dao.address, this.dollar.address, this.univ2.address, this.oracle.address);

    //this.pool.a().on('data', event => console.log('a', event));

  });

  describe('frozen', function () {
    describe('starts as frozen', function () {
      it('mints new Dollar tokens', async function () {
        expect(await this.pool.statusOf(userAddress)).to.be.bignumber.equal(FROZEN);
      });
    });

    describe('when deposit', function () {
      beforeEach(async function () {
        await this.univ2.faucet(userAddress, 1000);
        await this.univ2.approve(this.pool.address, 1000, {from: userAddress});

        this.result = await this.pool.deposit(1000, {from: userAddress});
        this.txHash = this.result.tx;
      });

      it('is frozen', async function () {
        expect(await this.pool.statusOf(userAddress)).to.be.bignumber.equal(FROZEN);
      });

      it('updates users balances', async function () {
        expect(await this.univ2.balanceOf(userAddress)).to.be.bignumber.equal(new BN(0));
        expect(await this.pool.balanceOfStaged(userAddress)).to.be.bignumber.equal(new BN(1000));
        expect(await this.pool.balanceOfBonded(userAddress)).to.be.bignumber.equal(new BN(0));
      });

      it('updates dao balances', async function () {
        expect(await this.univ2.balanceOf(this.pool.address)).to.be.bignumber.equal(new BN(1000));
        expect(await this.pool.totalBonded()).to.be.bignumber.equal(new BN(0));
        expect(await this.pool.totalStaged()).to.be.bignumber.equal(new BN(1000));
      });

      it('emits Deposit event', async function () {
        const event = await expectEvent.inTransaction(this.txHash, MockPool, 'Deposit', {
          account: userAddress
        });

        expect(event.args.value).to.be.bignumber.equal(new BN(1000));
      });
    });

    describe('when withdraw', function () {
      describe('simple', function () {
        beforeEach(async function () {
          await this.univ2.faucet(userAddress, 1000);
          await this.univ2.approve(this.pool.address, 1000, {from: userAddress});
          await this.pool.deposit(1000, {from: userAddress});
        });

        it('check user balanaces', async function () {
          //expect(await this.univ2.balanceOf(userAddress)).to.be.bignumber.equal(new BN(1000),'univ2.balanceOf!=1000');
          expect(await this.pool.balanceOfStaged(userAddress)).to.be.bignumber.equal(new BN(1000),'pool.balanceOfStaged!=1000');
          expect(await this.pool.balanceOfBonded(userAddress)).to.be.bignumber.equal(new BN(0),'pool.balanceOfBonded!=0');
        });

        it('check withdraw status', async function () {
          expect(await this.pool.allowWithdrawInExpansion()).equal(true,'allowWithdrawInExpansion!=true');
          expect(await this.pool.allowWithdrawInContraction()).equal(false,'allowWithdrawInContraction!=true');
        });

        it('check withdraw fee', async function () {
          expect(await this.pool.getExitInContractionFee()).to.be.bignumber.equal(new BN(300),'getExitInContractionFee!=300');
          expect(await this.pool.getExitInExpansionFee()).to.be.bignumber.equal(new BN(20),'getExitInExpansionFee!=20');
        });

        it('check withdraw allowance', async function () {
          expect(await this.pool.getExitInContractionFee()).to.be.bignumber.equal(new BN(300),'getExitInContractionFee!=300');
          expect(await this.pool.getExitInExpansionFee()).to.be.bignumber.equal(new BN(20),'getExitInExpansionFee!=20');
        });

        it('at $1.2: withdraw $100 and tax 2%', async function () {
          const price = 120;
          await this.oracle.set(price, 100, true);
          expect(await priceForToBN(this.oracle)).to.be.bignumber.equal(cents(price),'p!='+price);
          const tx = await this.pool.withdraw(100, {from: userAddress});
          events(tx);
          const totalStaged = await this.pool.totalStaged();
          const univ2 = await this.univ2.balanceOf(userAddress);
          const treasure = await this.univ2.balanceOf(await this.pool.getTaxTreasure());
          expect(totalStaged).to.be.bignumber.equal(new BN(900),'pool.totalStaged!=900');
          expect(univ2).to.be.bignumber.equal(new BN(98),'univ2!=98');
          expect(treasure).to.be.bignumber.equal(new BN(2),'treasure!=2');
          //await expectRevert(this.pool.withdraw(1000, {from: userAddress}), "WITHDRAW MUST FAIL AT CONTRACTION.");
        });

        it('at $1.02: withdraw $100 and tax 30%', async function () {
          const price = 102;
          await this.oracle.set(price, 100, true);
          expect(await priceForToBN(this.oracle)).to.be.bignumber.equal(cents(price),'p!='+price);
          await this.pool.setAllowWithdrawInContraction(true, {from: ownerAddress});
          const tx = await this.pool.withdraw(100, {from: userAddress});
          events(tx);
          const totalStaged = await this.pool.totalStaged();
          const univ2 = await this.univ2.balanceOf(userAddress);
          const treasure = await this.univ2.balanceOf(await this.pool.getTaxTreasure());
          expect(totalStaged).to.be.bignumber.equal(new BN(900),'pool.totalStaged!=900');
          expect(univ2).to.be.bignumber.equal(new BN(70),'univ2!=70');
          expect(treasure).to.be.bignumber.equal(new BN(30),'treasure!=30');
          //await expectRevert(this.pool.withdraw(1000, {from: userAddress}), "WITHDRAW MUST FAIL AT CONTRACTION.");
        });

        it('at $1.02: deny withdraw $100', async function () {
          const price = 102;
          await this.oracle.set(price, 100, true);
          expect(await priceForToBN(this.oracle)).to.be.bignumber.equal(cents(price),'p!='+price);
          await this.pool.setAllowWithdrawInContraction(false, {from: ownerAddress});
          await expectRevert(this.pool.withdraw(100, {from: userAddress}), "ERR-Co-nWD");
          const totalStaged = await this.pool.totalStaged();
          const univ2 = await this.univ2.balanceOf(userAddress);
          const treasure = await this.univ2.balanceOf(await this.pool.getTaxTreasure());
          expect(totalStaged).to.be.bignumber.equal(new BN(1000),'pool.totalStaged!=1000');
          expect(univ2).to.be.bignumber.equal(new BN(0),'univ2!=0');
          expect(treasure).to.be.bignumber.equal(new BN(0),'treasure!=0');

        });


      });

      /*
      describe('too much', function () {
        beforeEach(async function () {
          await this.univ2.faucet(userAddress, 1000);
          await this.univ2.approve(this.pool.address, 1000, {from: userAddress});
          await this.pool.deposit(1000, {from: userAddress});

          await this.univ2.faucet(userAddress1, 10000);
          await this.univ2.approve(this.pool.address, 10000, {from: userAddress1});
          await this.pool.deposit(10000, {from: userAddress1});
        });

        it('reverts', async function () {
          await expectRevert(this.pool.withdraw(2000, {from: userAddress}), "insufficient staged balance");
        });
      });
      */
    });
  });
});