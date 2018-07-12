import { getBouncerSigner } from '../../helpers/sign';

const MintableToken = artifacts.require('MintableToken');
const ERC20AirDropper = artifacts.require('ERC20Airdropper');

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(web3.BigNumber))
  .should();

contract('ERC20Airdropper', function ([_, owner, delegate, anyone]) {
  beforeEach(async function () {
    this.token = await MintableToken.new({ from: owner });
    console.log(web3.eth.estimateGas({
      data: ERC20AirDropper.bytecode,
      from: owner,
    }));
    this.airdrop = await ERC20AirDropper.new(this.token.address, { from: owner });

    await this.token.transferOwnership(this.airdrop.address, { from: owner });
    await this.airdrop.addDelegate(delegate, { from: owner });

    this.signFor = getBouncerSigner(this.airdrop, delegate);
  });

  it('should work', async function () {
    const sig = this.signFor(anyone, 'mint', [anyone, 1]);

    console.log(await this.airdrop.mint.estimateGas(anyone, 1, sig, { from: anyone }));

    await this.airdrop.mint(anyone, 1, sig, { from: anyone });

    const tokenBalance = await this.token.balanceOf(anyone);
    tokenBalance.should.be.bignumber.eq(1);
  });
});
