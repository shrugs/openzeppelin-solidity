pragma solidity ^0.4.24;

/**
 * @title BytesConverter
 * @dev Various byte conversion utilities.
 * Inspired by https://github.com/0xProject/0x-monorepo/blob/development/packages/contracts/src/2.0.0/utils/LibBytes/LibBytes.sol
 */
library BytesConverter {

  /**
   * @dev Converts bytes argument to bytes32 at offset _index
   * @param _arg bytes array
   * @param _index uint256 offset of the bytes32 within the bytes array
   */
  function toBytes32(bytes memory _arg, uint256 _index)
    public
    pure
    returns (bytes32 res)
  {
    // Arrays are prefixed by a 32 byte length parameter
    uint256 index = _index + 32;

    require(
      _arg.length >= index,
      "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
    );

    // solium-disable-next-line security/no-inline-assembly
    assembly {
      res := mload(add(_arg, index))
    }
  }
}
