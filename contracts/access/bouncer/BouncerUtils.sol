pragma solidity 0.4.24;


/**
 * @title BouncerUtils
 * @author Matt Condon (@Shrugs)
 * @dev Provides helpful logic for verifying method parameters.
 */
library BouncerUtils {
  /**
   * @dev returns msg.data, sans the last `_ticketsLength` bytes
   */
  function getMessageData(uint256 _ticketsLength)
    internal
    pure
    returns (bytes)
  {
    require(msg.data.length > _ticketsLength, "MSG_DATA_NOT_GT_TICKETS_LENGTH");

    bytes memory data = new bytes(msg.data.length - _ticketsLength);
    for (uint i = 0; i < data.length; i++) {
      data[i] = msg.data[i];
    }

    return data;
  }

  function messageDataHash(uint256 _ticketsLength)
    internal
    view
    returns (bytes32)
  {
    return keccak256(
      abi.encodePacked(
        address(this),
        getMessageData(_ticketsLength)
      )
    );
  }
}
