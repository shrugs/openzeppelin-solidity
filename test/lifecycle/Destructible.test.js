const DestructibleMock = artifacts.require('DestructibleMock');

contract('Destructible', function (accounts) {
  beforeEach(async function () {
    this.destructible = await DestructibleMock.new({ from: accounts[0] });
    await pweb3.eth.sendTransaction({
      from: accounts[0],
      to: this.destructible.address,
      value: web3.toWei('10', 'ether'),
    });

    this.owner = await this.destructible.owner();
  });

  it('should send balance to owner after destruction', async function () {
    const initBalance = await pweb3.eth.getBalance(this.owner);
    await this.destructible.destroy({ from: this.owner });
    const newBalance = await pweb3.eth.getBalance(this.owner);
    assert.isTrue(newBalance > initBalance);
  });

  it('should send balance to recepient after destruction', async function () {
    const initBalance = await pweb3.eth.getBalance(accounts[1]);
    await this.destructible.destroyAndSend(accounts[1], { from: this.owner });
    const newBalance = await pweb3.eth.getBalance(accounts[1]);
    assert.isTrue(newBalance.greaterThan(initBalance));
  });
});
