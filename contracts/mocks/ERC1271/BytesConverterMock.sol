pragma solidity ^0.4.24;

import "../../proposals/ERC1271/BytesConverter.sol";


contract BytesConverterMock {
  using BytesConverter for bytes;

  function toBytes32(bytes _arg, uint256 _index)
    public
    pure
    returns (bytes32)
  {
    return _arg.toBytes32(_index);
  }
}
