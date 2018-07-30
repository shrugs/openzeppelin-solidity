const { expectThrow } = require('../helpers/expectThrow');

const HasNoEtherTest = artifacts.require('HasNoEtherTest');
const ForceEther = artifacts.require('ForceEther');

contract('HasNoEther', function (accounts) {
  const amount = web3.toWei('1', 'ether');

  it('should be constructible', async function () {
    await HasNoEtherTest.new();
  });

  it('should not accept ether in constructor', async function () {
    await expectThrow(HasNoEtherTest.new({ value: amount }));
  });

  it('should not accept ether', async function () {
    const hasNoEther = await HasNoEtherTest.new();

    await expectThrow(
      pweb3.eth.sendTransaction({
        from: accounts[1],
        to: hasNoEther.address,
        value: amount,
      }),
    );
  });

  it('should allow owner to reclaim ether', async function () {
    // Create contract
    const hasNoEther = await HasNoEtherTest.new();
    const startBalance = await pweb3.eth.getBalance(hasNoEther.address);
    assert.equal(startBalance, 0);

    // Force ether into it
    const forceEther = await ForceEther.new({ value: amount });
    await forceEther.destroyAndSend(hasNoEther.address);
    const forcedBalance = await pweb3.eth.getBalance(hasNoEther.address);
    assert.equal(forcedBalance, amount);

    // Reclaim
    const ownerStartBalance = await pweb3.eth.getBalance(accounts[0]);
    await hasNoEther.reclaimEther();
    const ownerFinalBalance = await pweb3.eth.getBalance(accounts[0]);
    const finalBalance = await pweb3.eth.getBalance(hasNoEther.address);
    assert.equal(finalBalance, 0);
    assert.isAbove(ownerFinalBalance, ownerStartBalance);
  });

  it('should allow only owner to reclaim ether', async function () {
    // Create contract
    const hasNoEther = await HasNoEtherTest.new({ from: accounts[0] });

    // Force ether into it
    const forceEther = await ForceEther.new({ value: amount });
    await forceEther.destroyAndSend(hasNoEther.address);
    const forcedBalance = await pweb3.eth.getBalance(hasNoEther.address);
    assert.equal(forcedBalance, amount);

    // Reclaim
    await expectThrow(hasNoEther.reclaimEther({ from: accounts[1] }));
  });
});
