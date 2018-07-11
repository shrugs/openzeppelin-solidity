
import assertRevert from '../helpers/assertRevert';
import { getBouncerSigner } from '../helpers/sign';
import makeInterfaceId from '../helpers/makeInterfaceId';

const Bouncer = artifacts.require('BouncerMock');
const BouncerDelegateImpl = artifacts.require('BouncerDelegateImpl');

require('chai')
  .use(require('chai-as-promised'))
  .should();

const UINT_VALUE = 23;
const BYTES_VALUE = web3.toHex('test');
const INVALID_SIGNATURE = '0xabcd';

contract('Bouncer', ([_, owner, authorizedUser, anyone, delegate, newDelegate]) => {
  before(async function () {
    this.bouncer = await Bouncer.new({ from: owner });
    this.roleDelegate = await this.bouncer.ROLE_DELEGATE();
    this.roleOwner = await this.bouncer.ROLE_OWNER();
    this.signFor = getBouncerSigner(this.bouncer, delegate);
  });

  it('should have a default owner', async function () {
    const hasRole = await this.bouncer.hasRole(owner, this.roleOwner);
    hasRole.should.eq(true);
  });

  it('should allow owner to add a delegate', async function () {
    await this.bouncer.addDelegate(delegate, { from: owner });
    const hasRole = await this.bouncer.hasRole(delegate, this.roleDelegate);
    hasRole.should.eq(true);
  });

  it('should not allow anyone to add a delegate', async function () {
    await assertRevert(
      this.bouncer.addDelegate(delegate, { from: anyone })
    );
  });

  context('modifiers', () => {
    it('should allow valid signature for sender', async function () {
      await this.bouncer.onlyWithValidSignature(
        this.signFor(authorizedUser),
        { from: authorizedUser }
      );
    });
    it('should not allow invalid signature for sender', async function () {
      await assertRevert(
        this.bouncer.onlyWithValidSignature(
          INVALID_SIGNATURE,
          { from: authorizedUser }
        )
      );
    });
    it('should allow valid signature with a valid method for sender', async function () {
      await this.bouncer.onlyWithValidSignatureAndMethod(
        this.signFor(authorizedUser, 'onlyWithValidSignatureAndMethod'),
        { from: authorizedUser }
      );
    });
    it('should not allow invalid signature with method for sender', async function () {
      await assertRevert(
        this.bouncer.onlyWithValidSignatureAndMethod(
          INVALID_SIGNATURE,
          { from: authorizedUser }
        )
      );
    });
    it('should allow valid signature with a valid data for sender', async function () {
      await this.bouncer.onlyWithValidSignatureAndData(
        UINT_VALUE,
        this.signFor(authorizedUser, 'onlyWithValidSignatureAndData', [UINT_VALUE]),
        { from: authorizedUser }
      );
    });
    it('should not allow invalid signature with data for sender', async function () {
      await assertRevert(
        this.bouncer.onlyWithValidSignatureAndData(
          UINT_VALUE,
          INVALID_SIGNATURE,
          { from: authorizedUser }
        )
      );
    });
  });

  context('signatures', () => {
    it('should accept valid message for valid user', async function () {
      const isValid = await this.bouncer.checkValidSignature(
        authorizedUser,
        this.signFor(authorizedUser)
      );
      isValid.should.eq(true);
    });
    it('should not accept invalid message for valid user', async function () {
      const isValid = await this.bouncer.checkValidSignature(
        authorizedUser,
        this.signFor(anyone)
      );
      isValid.should.eq(false);
    });
    it('should not accept invalid message for invalid user', async function () {
      const isValid = await this.bouncer.checkValidSignature(
        anyone,
        'abcd'
      );
      isValid.should.eq(false);
    });
    it('should not accept valid message for invalid user', async function () {
      const isValid = await this.bouncer.checkValidSignature(
        anyone,
        this.signFor(authorizedUser)
      );
      isValid.should.eq(false);
    });
    it('should accept valid message with valid method for valid user', async function () {
      const isValid = await this.bouncer.checkValidSignatureAndMethod(
        authorizedUser,
        this.signFor(authorizedUser, 'checkValidSignatureAndMethod')
      );
      isValid.should.eq(true);
    });
    it('should not accept valid message with an invalid method for valid user', async function () {
      const isValid = await this.bouncer.checkValidSignatureAndMethod(
        authorizedUser,
        this.signFor(authorizedUser, 'theWrongMethod')
      );
      isValid.should.eq(false);
    });
    it('should not accept valid message with a valid method for an invalid user', async function () {
      const isValid = await this.bouncer.checkValidSignatureAndMethod(
        anyone,
        this.signFor(authorizedUser, 'checkValidSignatureAndMethod')
      );
      isValid.should.eq(false);
    });
    it('should accept valid method with valid params for valid user', async function () {
      const isValid = await this.bouncer.checkValidSignatureAndData(
        authorizedUser,
        BYTES_VALUE,
        UINT_VALUE,
        this.signFor(authorizedUser, 'checkValidSignatureAndData', [authorizedUser, BYTES_VALUE, UINT_VALUE])
      );
      isValid.should.eq(true);
    });
    it('should not accept valid method with invalid params for valid user', async function () {
      const isValid = await this.bouncer.checkValidSignatureAndData(
        authorizedUser,
        BYTES_VALUE,
        500,
        this.signFor(authorizedUser, 'checkValidSignatureAndData', [authorizedUser, BYTES_VALUE, UINT_VALUE])
      );
      isValid.should.eq(false);
    });
    it('should not accept valid method with valid params for invalid user', async function () {
      const isValid = await this.bouncer.checkValidSignatureAndData(
        anyone,
        BYTES_VALUE,
        UINT_VALUE,
        this.signFor(authorizedUser, 'checkValidSignatureAndData', [authorizedUser, BYTES_VALUE, UINT_VALUE])
      );
      isValid.should.eq(false);
    });
  });

  context('management', () => {
    it('should not allow anyone to add delegates', async function () {
      await assertRevert(
        this.bouncer.addDelegate(newDelegate, { from: anyone })
      );
    });

    it('should be able to add delegate', async function () {
      await this.bouncer.addDelegate(newDelegate, { from: owner })
        .should.be.fulfilled;
    });

    it('should not allow adding invalid address', async function () {
      await assertRevert(
        this.bouncer.addDelegate('0x0', { from: owner })
      );
    });

    it('should not allow anyone to remove delegate', async function () {
      await assertRevert(
        this.bouncer.removeDelegate(newDelegate, { from: anyone })
      );
    });

    it('should be able to remove delegates', async function () {
      await this.bouncer.removeDelegate(newDelegate, { from: owner })
        .should.be.fulfilled;
    });
  });

  context('contract delegate', () => {
    context('not a delegate', () => {
      beforeEach(async function () {
        this.delegateContract = await BouncerDelegateImpl.new(true, this.bouncer.address, { from: owner });
      });

      it('should fail', async function () {
        await assertRevert(
          this.delegateContract.forward({ from: anyone })
        );
      });
    });

    context('invalid delegate', () => {
      beforeEach(async function () {
        this.delegateContract = await BouncerDelegateImpl.new(false, this.bouncer.address, { from: owner });
        await this.bouncer.addDelegate(this.delegateContract.address, { from: owner });
      });

      it('should be invalid', async function () {
        await assertRevert(
          this.delegateContract.forward({ from: anyone })
        );
      });
    });

    context('valid delegate', () => {
      beforeEach(async function () {
        this.delegateContract = await BouncerDelegateImpl.new(true, this.bouncer.address, { from: owner });
        await this.bouncer.addDelegate(this.delegateContract.address, { from: owner });
      });

      it('should support isValidSignature', async function () {
        const supported = await this.delegateContract.supportsInterface(makeInterfaceId([
          'isValidSignature(bytes32,bytes)',
        ]));
        supported.should.eq(true);
      });

      it('should be valid', async function () {
        await this.delegateContract.forward({ from: anyone });
      });
    });
  });
});
