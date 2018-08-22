pragma solidity ^0.4.24;

import "../../proposals/ERC1271/BytesConverter.sol";


contract BytesConverterMock {
  using BytesConverter for bytes;

  function readBytes32(bytes memory _arg, uint256 _index)
    public
    pure
    returns (bytes32)
  {
    return _arg.readBytes32(_index);
  }
}
