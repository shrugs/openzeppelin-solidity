pragma solidity ^0.4.24;

import "../access/bouncer/BouncerWithTrustedSigners.sol";


contract BouncerMock is BouncerWithTrustedSigners {
  function checkValidTickets(
    address _address,
    bytes,
    uint,
    bytes _tickets
  )
    public
    view
    returns (bool)
  {
    return validTickets(_tickets);
  }

  function onlyWithValidTickets(uint, bytes _tickets)
    public
    onlyValidTickets(_tickets)
    view
  {

  }

  function theWrongMethod(bytes)
    public
    pure
  {

  }
}
