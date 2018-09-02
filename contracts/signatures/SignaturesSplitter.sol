pragma solidity ^0.4.24;

/**
 * @title SignaturesSplitter
 * @author Ricardo Guilherme Schmidt (Status Research & Development GmbH)
 * @author Richard Meissner - <richard@gnosis.pm>
 * @dev Splits signatures.
 * Original Source: https://github.com/gnosis/safe-contracts/blob/development/contracts/common/SignatureDecoder.sol
 */
library SignaturesSplitter {

  // gets the first uint8 of a bytes array after the 32 byte length int
  function getV(bytes _signature)
    internal
    pure
    returns (
      uint8 v
    )
  {
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      // 'byte' is not working due to the Solidity parser, so lets
      // use the second best option, 'and'
      v := and(mload(add(_signature, 0x20)), 0xff)
    }
  }

  // gets the r value of a signature
  function getR(bytes _signature)
    internal
    pure
    returns (
      bytes32 r
    )
  {
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_signature, 0x21))
    }
  }

  // gets the s value of a signature
  function getS(bytes _signature)
    internal
    pure
    returns (
      bytes32 s
    )
  {
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      s := mload(add(_signature, 0x41))
    }
  }

  function getContractSignature(bytes _signature)
    internal
    pure
    returns (
      bytes memory sig
    )
  {
    bytes32 s = getS(_signature);
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      // The signature data for contract signatures is appended to the concatenated signatures and the offset is stored in s
      sig := add(add(_signature, s), 0x20)
    }
  }

  function signatureAt(bytes _signature, uint256 _i)
    internal
    pure
    returns (
      bytes memory sig
    )
  {
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      sig := add(_signature, add(0x20, mul(0x41, _i))) // 32 + (65 * i)
    }
  }

  /**
   * @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`
   * @param pos which signature to read
   * @param signatures concatenated rsv signatures
   */
  function splitSignaturesVRS(bytes signatures, uint256 pos)
    internal
    pure
    returns (
      uint8 v,
      bytes32 r,
      bytes32 s
    )
  {
    // The signature format is a compact form of:
    //   {uint8 v}{bytes32 r}{bytes32 s}
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      let signaturePos := mul(0x41, pos) // 65 * i
      // 'byte' is not working due to the Solidity parser, so lets
      // use the second best option, 'and'
      v := and(mload(add(signatures, add(signaturePos, 0x20))), 0xff)

      r := mload(add(signatures, add(signaturePos, 0x21)))
      s := mload(add(signatures, add(signaturePos, 0x41)))
    }
  }
  /**
   * @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`
   * @param pos which signature to read
   * @param signatures concatenated rsv signatures
   */
  function signatureSplit(bytes signatures, uint256 pos)
    internal
    pure
    returns (
      uint8 v,
      bytes32 r,
      bytes32 s
    )
  {
    // The signature format is a compact form of:
    //   {bytes32 r}{bytes32 s}{uint8 v}
    // Compact means, uint8 is not padded to 32 bytes.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      let signaturePos := mul(0x41, pos) // 65 * i
      r := mload(add(signatures, add(signaturePos, 0x20)))
      s := mload(add(signatures, add(signaturePos, 0x40)))
      // Here we are loading the last 32 bytes, including 31 bytes
      // of 's'. There is no 'mload8' to do this.
      //
      // 'byte' is not working due to the Solidity parser, so lets
      // use the second best option, 'and'
      v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
    }
  }
}
