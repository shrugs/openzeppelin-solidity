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

  function isValidSignature(
    bytes _data,
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
    bool isValid = _data.isSignedBy(nextSigner, sig);

    return hasPermission && isValid;
  }
}
