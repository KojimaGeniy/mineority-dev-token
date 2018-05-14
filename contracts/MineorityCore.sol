pragma solidity ^0.4.23;
import "./MineorityMint.sol";

contract MineorityCore is MineorityMint {

    //**Main contract with all admin stuff**//
  
    constructor() public {
      // constructor
    }

    function() external payable {
        //require(
          //msg.sender == address of some of our contracts
        //);
    }

    //* Switch token status from maintenance to active and opposite
    function switchStatus(uint256 _tokenId) public /*ownerOnly*/ {
        allTokens[_tokenId].tokenStatus == Status.Active ? 
            allTokens[_tokenId].tokenStatus = Status.Maintenance : 
            allTokens[_tokenId].tokenStatus = Status.Active;
    }

    //* Returns all information of a given token
    // check return datatypes to be all 256 or what
    // same with minting
    function getToken(uint256 _tokenId) public view
        returns (
          uint128 asicID,
          uint256 GPUType,
          uint256 status
    ) {
        Token storage tok = allTokens[_tokenId];

        asicID = tok.asicID;
        GPUType = uint256(tok.GPUType);
        status = uint256(tok.tokenStatus);
    }
}
