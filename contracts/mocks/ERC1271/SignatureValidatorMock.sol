pragma solidity ^0.4.24;

import "../../proposals/ERC1271/SignatureValidator.sol";


contract SignatureValidatorMock is SignatureValidator {

  bool public shouldSucceed = false;

  constructor(bool _shouldSucceed)
    public
  {
    shouldSucceed = _shouldSucceed;
  }

  function isValidSignature(
    bytes,
    bytes
  )
    external
    view
    returns (bool)
  {
    return shouldSucceed;
  }
}
