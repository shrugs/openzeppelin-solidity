pragma solidity ^0.4.24;

import "./BouncerUtils.sol";
import "../../signatures/SignatureChecker.sol";
import "../../signatures/BytesConverter.sol";


/**
 * @title Bouncer
 * @author Shrugs, PhABC, and aflesher
 * @dev Bouncer allows arbitrary addresses to submit a signature (or "ticket") as a permission to do an action.
 * See BouncerWithTrustedSigners and BouncerMock for example usage.
 * @notice A method that uses the `onlyValidTickets` modifier must make the _signature
 * parameter the last parameter.
 */
contract Bouncer is SignatureChecker {

  // a bouncer is a signature checker that assumes the datahash
  modifier onlyValidTickets(bytes _tickets)
  {
    require(validTickets(_tickets), "INVALID_TICkETS");
    _;
  }

  function validTickets(bytes _tickets)
    internal
    view
    returns (bool)
  {
    return validSignatures(
      BytesConverter.toBytes(BouncerUtils.messageDataHash(_tickets.length)),
      _tickets
    );
  }
}
