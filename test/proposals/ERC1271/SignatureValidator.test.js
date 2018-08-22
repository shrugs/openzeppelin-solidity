const { expectThrow } = require('../../helpers/expectThrow');
const { personalSignMessage, soliditySha3 } = require('../../helpers/sign');

const SignatureValidatorMock = artifacts.require('SignatureValidatorMock');
const SignatureCheckerMock = artifacts.require('SignatureCheckerMock');
const SimpleIdentityMock = artifacts.require('SimpleIdentityMock');

require('chai')
  .should();

const MOCK_DATA = soliditySha3('Hello World!');

const constructSignatureforData = (data, signers = []) => {
  if (!signers.length) {
    throw new Error('must be signed by _someone_');
  }

  // given data, sign it using the last signer in signer
  const lastSigner = signers[signers.length - 1];
  const signature = personalSignMessage(lastSigner, data);
  // then construct a bytes array that compacts all of the signers and the final signature
  const finalSignature = Buffer.concat(
    signers.map((s) => Buffer.from(s.slice(2), 'hex'))
      .concat([
        Buffer.from(signature.slice(2), 'hex'),
      ])
  ).toString('hex');

  console.log('data:', data);
  console.log('signers:', signers);
  console.log('final:', finalSignature);

  return `0x${finalSignature}`;
};

contract.only('SignatureChecker', function ([_, user, signer]) {
  beforeEach(async function () {
    this.checker = await SignatureCheckerMock.new({ from: user });
  });

  describe('splitNextSignerAndSig', function () {
    it('should split signer and signature correctly', async function () {
      const signature = constructSignatureforData(MOCK_DATA, signer);
      const res = await this.checker.splitNextSignerAndSig(signature);
      console.log(res);
    });
  });
});

contract.only('SignatureValidator', function ([_, user, authorized, invalid]) {
  beforeEach(async function () {
    this.checker = await SignatureCheckerMock.new({ from: user });
  });

  describe('isValidSignature', function () {
    context('with invalid contract signature', function () {
      beforeEach(async function () {
        this.mock = await SignatureValidatorMock.new(false, { from: user });
      });

      it('should return false', async function () {
        const signature = constructSignatureforData(MOCK_DATA, [authorized]);
        (await this.checker.isSignedBy(
          MOCK_DATA,
          authorized,
          signature,
        )).should.equal(false);
      });
    });

    context('with valid contract signature', function () {
      beforeEach(async function () {
        this.mock = await SignatureValidatorMock.new(true, { from: user });
      });

      it('should return true', async function () {
        const signature = constructSignatureforData(MOCK_DATA, [authorized]);
        (await this.checker.isSignedBy(
          MOCK_DATA,
          authorized,
          signature,
        )).should.equal(true);
      });
    });

    context('with invalid chain but valid signature', function () {
      // sign with valid user, but us invalid signer in chain
    });

    context('with valid chain but invalid signaute', function () {
      // sign with invalid user but use valid chain
    });

    context('with invalid EOA signature', function () {

    });

    context('with valid EOA signature', function () {

    });
  });

  context('using identity', function () {
    beforeEach(async function () {
      this.identity = await SimpleIdentityMock.new({ from: user });
      await this.identity.addSigner(authorized, { from: user });
    });

    context('Identity owned by EOA', function () {
      it('should validate authorized signed data');
    });

    context('Identity owned by Identity', function () {

    });
  });
});
