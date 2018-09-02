pragma solidity ^0.4.24;

import "./SignaturesSplitter.sol";
import "./ISignatureValidator.sol";
import "./BytesConverter.sol";
import "./ECRecovery.sol";


contract SignatureChecker {
  using ECRecovery for bytes32;

  // signature size is 65 bytes (tightly packed v (1) + r (32) + s (32))
  uint256 constant SIGNATURE_SIZE = 65;

  /**
   * @dev requires that a valid set of tickets was provided
   */
  modifier onlyValidSignatures(bytes _data, bytes _signatures)
  {
    require(validSignatures(_data, _signatures), "INVALID_SIGNATURES");
    _;
  }

  function numSignatures(bytes _signatures)
    internal
    pure
    returns (uint256)
  {
    return _signatures.length / SIGNATURE_SIZE;
  }

  function validSignaturesLength(bytes _signatures)
    internal
    pure
    returns (bool)
  {
    return (_signatures.length % SIGNATURE_SIZE) == 0;
  }

  function validSignatures(bytes _data, bytes _signatures)
    internal
    view
    returns (bool)
  {
    uint256 numSigs = numSignatures(_signatures);
    if (!validSignaturesLength(_signatures)) {
      return false;
    }

    // There cannot be asigner with address 0
    address lastSigner = address(0);
    address currentSigner;
    bytes memory currentSignerSignature;
    bool isContract;

    for (uint256 i = 0; i < numSigs; i++) {
      // @TODO - this assumes signatures are signed by web3.eth.sign, which outputs vrs but
      // we should probably move to signTypedData, which is rsv
      bytes memory signature = SignaturesSplitter.signatureAt(_signatures, i);

      // get signer and signature
      (currentSigner, currentSignerSignature, isContract) = signerOf(signature, _data);

      // signer must be authenticated and authorized to sign for this data
      if (!(isAuthenticated(currentSigner) && isAuthorized(currentSigner, _data))) {
        return false;
      }

      // confirm that they've actually signed this
      if (!isSignedBy(_data, currentSigner, currentSignerSignature, isContract)) {
        return false;
      }

      // duplicated signature or improper order
      if (currentSigner <= lastSigner) {
        return false;
      }

      lastSigner = currentSigner;
    }

    return true;
  }

  function signerOf(bytes _signature, bytes _data)
    internal
    pure
    returns (
      address signer,
      bytes memory signature,
      bool isContract
    )
  {
    uint8 v = SignaturesSplitter.getV(_signature);
    // If v is 0 then it is a contract signature
    if (v == 0) {
      // When handling contract signatures the address of the contract is encoded into r
      signer = address(SignaturesSplitter.getR(_signature));
      signature = SignaturesSplitter.getContractSignature(_signature);
      isContract = true;
    } else {
      // for EOA accounts, signer is encoded in vrs for relevant data hash
      signature = _signature;
      signer = BytesConverter.toBytes32(_data, 0)
        .toEthSignedMessageHash()
        .recover(signature);
    }
  }

  function isSignedBy(
    bytes _data,
    address _signer,
    bytes _signature,
    bool isContract
  )
    internal
    view
    returns (bool)
  {
    if (isContract) {
      // contract
      return ISignatureValidator(_signer).isValidSignature(_data, _signature);
    } else {
      // EOA
      return _signer == BytesConverter.toBytes32(_data, 0)
        .toEthSignedMessageHash()
        .recover(_signature);
    }
  }

  /**
   * @dev Whether or not `_signer` is authenticated within the context of this SignatureChecker
   * param _signer signer
   */
  function isAuthenticated(address)
    internal
    view
    returns (bool)
  {
    require(address(this) == 0, "INHERIT_ME"); // address(this) removes solc state read warning
  }

  /**
   * @dev Whether or not `_signer` is authorized to sign for `_data`
   * param _signer signer
   * param _data data
   */
  function isAuthorized(address, bytes)
    internal
    view
    returns (bool)
  {
    require(address(this) == 0, "INHERIT_ME"); // address(this) removes solc state read warning
  }
}
