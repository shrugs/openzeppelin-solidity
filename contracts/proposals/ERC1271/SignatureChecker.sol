pragma solidity ^0.4.24;

import "../../ECRecovery.sol";
import "../../introspection/ERC165Checker.sol";

import "./BytesConverter.sol";
import "./ISignatureValidator.sol";

/**
 * @title SignatureChecker
 * @dev Use this library to check the signatures provided by EOA accounts.
 * This library correctly recurses through a tightly packed signature array, deferring validation to
 * the subsequent authorized signer.
 */
library SignatureChecker {
  using BytesConverter for bytes;
  using ERC165Checker for address;

  /**
   * @dev given a bytes array, split the array into [address, ...rest]
   * ignoring the 32 byte length at the beginning
   */
  function splitNextSignerAndSig(bytes memory _sig)
    internal
    pure
    returns (address addr, bytes memory rest)
  {
    // bytes array has 32 bytes of length param at the beginning
    uint256 addrIndex = 32;
    uint256 sigIndex = addrIndex + 20;

    // solium-disable-next-line security/no-inline-assembly
    assembly {
      addr := mload(add(_sig, addrIndex))
      rest := add(_sig, sigIndex)
    }
  }

  /**
   * @dev checks to see if _data was signed by _signer with _signature, delegating to _signer if it supports isValidSignature
   * @param _data bytes32 the data claimed to be signed
   * @param _signer address the claimed signer of the data
   * @param _signature bytes the provided sigature for the _data by _signer
   */
  function isSignedBy(bytes _data, address _signer, bytes _signature)
    internal
    view
    returns (bool)
  {
    // if the signer address supports signature validation, ask for its permissions/validity
    // which means _signature can be anything
    // 0x20c13b0b === bytes4(keccak256('isValidSignature(bytes,bytes)')), inlined to keep this as a library
    if (_signer.supportsInterface(0x20c13b0b)) {
      return ISignatureValidator(_signer).isValidSignature(_data, _signature);
    }


    // otherwise make sure the hash was personally signed by the EOA account
    // which means _sig should be highly compacted vrs
    bytes32 signedHash = ECRecovery.toEthSignedMessageHash(_data.toBytes32(0));
    return _signer == ECRecovery.recover(signedHash, _signature);
  }
}
