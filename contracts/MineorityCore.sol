pragma solidity ^0.4.23;
import "./MineorityMint.sol";

contract MineorityCore is MineorityMint {

    //**Main contract with all admin stuff**//
  
    constructor() public {
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;
    }

    function() external payable {
        //require(
          //msg.sender == address of some of our contracts
        //);
    }

    //* Returns all information of a given token
    // check return datatypes to be all 256 or what
    // same with minting
    function getToken(uint256 _tokenId) public view
        returns (
          uint256 asicID,
          uint256 pciVendorID,
          uint256 pciDeviceID,
          uint256 pciSubDeviceID,
          uint256 pciSubVendorID,
          uint256 memSizeMB,
          string memInfo,
          uint256 GPUType
    ) {
        Token storage tok = allTokens[_tokenId];

        asicID = uint256(tok.asicID);
        pciVendorID = uint256(tok.pciVendorID);
        pciDeviceID = uint256(tok.pciDeviceID);
        pciSubDeviceID = uint256(tok.pciSubDeviceID);
        pciSubVendorID = uint256(tok.pciSubVendorID);
        memSizeMB = uint256(tok.memSizeMB);
        memInfo = tok.memInfo;
        GPUType = uint256(tok.GPUType);
    }

    //* For now it'll be there
    function withdrawFunds() public /*OnlyCFO*/{
        cfoAddress.transfer(this.balance);
    }
}
