pragma solidity ^0.4.24;

import "../../proposals/ERC1271/SignatureChecker.sol";


contract SignatureCheckerMock {
  using SignatureChecker for bytes;

  function splitNextSignerAndSig(bytes _signature)
    public
    pure
    returns (address addr, bytes memory sig)
  {
    (addr, sig) = _signature.splitNextSignerAndSig();
  }

  function isSignedBy(bytes _data, address _signer, bytes _signature)
    public
    view
    returns (bool)
  {
    return _data.isSignedBy(_signer, _signature);
  }
}
