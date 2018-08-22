pragma solidity ^0.4.24;

import "./ISignatureValidator.sol";
import "../../introspection/ERC165.sol";
import "../../introspection/SupportsInterfaceWithLookup.sol";

/**
 * @title SignatureValidator
 * @dev Implementation of ISignatureValidator using SupportsInterfaceWithLookup
 */
contract SignatureValidator is ERC165, SupportsInterfaceWithLookup, ISignatureValidator {
  bytes4 internal constant InterfaceId_SignatureValidator = 0x20c13b0b;
  /**
   * 0x20c13b0b ===
   *   bytes4(keccak256('isValidSignature(bytes,bytes)'))
   */


  constructor()
    public
  {
    _registerInterface(InterfaceId_SignatureValidator);
  }

  /**
   * @dev Here, you must do a few things:
   * 1. Pull the signer and the rest of the signature from the _signature argument using `(nextSigner, sig) = splitNextSignerAndSig(_sig);`
   * 2. Check the _permission_ of nextSigner to see if they are allowed to sign something (anything) on your behalf.
   *    IF you're an Identity contract, you want to check to see if this nextSigner is an authorized key with an ACTION permission, for example.
   *    IF you're a Multisig, you want to check to see if this nextSigner is one of the owners
   *    You can also implement your own logic entirely (like for implementing threshold signatures or whatever).
   * 3. Check the _validity_ of `nextSigner`'s `sig` for `_data`
   * 4. If the nextSigner has permission and is valid, return true, otherwise return false.
   */
  function isValidSignature(
    bytes,
    bytes
  )
    external
    view
    returns (bool)
  {
    // Must override me!
    return false;
  }
}
