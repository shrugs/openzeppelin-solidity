pragma solidity ^0.4.24;


interface ISignatureValidator {
  /**
   * @dev verifies that a signature for an action is valid
   * https://eips.ethereum.org/EIPS/eip-1271
   * @param _data action data that is signed
   * @param _signature the provided signature
   * @return bool validity of the action and the signature
   */
  function isValidSignature(
    bytes _data,
    bytes _signature
  )
    external
    view
    returns (bool isValid);
}
