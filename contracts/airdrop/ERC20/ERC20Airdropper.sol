pragma solidity ^0.4.24;

import "../../access/Bouncer.sol";
import "../../token/ERC20/MintableToken.sol";


contract ERC20Airdropper is Bouncer {

  MintableToken public token ;

  constructor (MintableToken _token)
    public
  {
    token = _token;
  }

  function mint(address _to, uint256 _amount, bytes _sig)
    onlyValidSignatureAndData(_sig)
    external
  {
    token.mint(_to, _amount);
  }
}
