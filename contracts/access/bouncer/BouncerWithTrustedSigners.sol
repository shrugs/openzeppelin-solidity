pragma solidity ^0.4.24;

import "./Bouncer.sol";
import "../rbac/Roles.sol";


/**
 * @title BouncerWithTrustedSigners
 * @dev Creates a Bouncer contract that understands the concept of a trusted signer.
 * Any trusted signer can add or remove other trusted signers, so this isn't particularly secure
 * against compromisation if your private keys are hanging out on a server.
 * If this is a concern to you, you may want to implement a more comprehensive security surface.
 */
contract BouncerWithTrustedSigners is Bouncer {
  using Roles for Roles.Role;

  Roles.Role private signers;

  modifier onlyTrustedSigner() {
    require(signers.has(msg.sender), "DOES_NOT_HAVE_SIGNER_ROLE");
    _;
  }

  constructor(address[] _signers)
    public
  {
    signers.addMany(_signers);
  }

  /**
   * @dev allows trusted signer to add additional signers
   */
  function addTrustedSigner(address _signer)
    public
    onlyTrustedSigner
  {
    require(_signer != address(0), "NULL_SIGNER");
    signers.add(_signer);
  }

  /**
   * @dev allows trusted signer to remove other signers
   * @param _signer signer
   */
  function removeTrustedSigner(address _signer)
    public
    onlyTrustedSigner
  {
    signers.remove(_signer);
  }

  function isTrustedSigner(address _signer)
    public
    view
    returns (bool)
  {
    return signers.has(_signer);
  }

  /**
   * @dev Whether or not `_signer` is authenticated within the context of this SignatureChecker
   * @param _signer signer
   */
  function isAuthenticated(address _signer)
    internal
    view
    returns (bool)
  {
    return isTrustedSigner(_signer);
  }

  /**
   * @dev Whether or not `_signer` is authorized to sign for `_data`
   */
  function isAuthorized(address, bytes)
    internal
    view
    returns (bool)
  {
    // any signer is authorized for any signature
    // replace this function if you want to support stuff like multisig thresholds
    return true;
  }
}
