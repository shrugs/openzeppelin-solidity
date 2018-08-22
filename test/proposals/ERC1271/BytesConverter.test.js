const { expectThrow } = require('../../helpers/expectThrow');

const BytesConverterMock = artifacts.require('BytesConverterMock');

require('chai')
  .should();

const MOCK_BYTES32_1 = web3.sha3('HELLO');
const MOCK_BYTES32_2 = web3.sha3('WORLD');
const MOCK_BYTES = `0x${MOCK_BYTES32_1.slice(0, 2)}${MOCK_BYTES32_2.slice(0, 2)}`;

contract.only('BytesConverter', function ([_, user]) {
  beforeEach(async function () {
    this.mock = await BytesConverterMock.new({ from: user });
  });

  it('should convert bytes to bytes32 at index 0', async function () {
    (await this.mock.toBytes32(MOCK_BYTES, 0, { from: user })).should.equal(MOCK_BYTES32_1);
  });

  it('should convert bytes to bytes32 at index > 0', async function () {
    (await this.mock.toBytes32(MOCK_BYTES, 32, { from: user })).should.equal(MOCK_BYTES32_2);
  });

  it('should throw when converting bytes to bytes32 wihtout enough information', async function () {
    await expectThrow(
      this.mock.toBytes32(MOCK_BYTES, 60, { from: user })
    );
  });
});
