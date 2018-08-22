pragma solidity ^0.4.24;

import "../../proposals/ERC1271/SignatureValidator.sol";
import "../../access/rbac/Roles.sol";
import "../../proposals/ERC1271/SignatureChecker.sol";


contract SimpleIdentityMock is SignatureValidator {
  using Roles for Roles.Role;
  using SignatureChecker for bytes;

  Roles.Role private signers;

  function addSigner(address _signer)
    public
  {
    signers.add(_signer);
  }

  /**
   * @dev An action is valid iff the _sig of the _action is from an key with the ACTION purpose
   * @param _action action that is signed
   * @param _sig [[address] [address] [...]] <address> <v> <r> <s>
   */
  function isValidSignature(
    bytes _action,
    bytes _sig
  )
    external
    view
    returns (bool)
  {
    (address nextSigner, bytes memory sig) = _sig.splitNextSignerAndSig();

    // permission
    bool hasPermission = signers.has(nextSigner);

    // validity
    bool isValid = _action.isSignedBy(nextSigner, sig);

    return hasPermission && isValid;
  }
}
