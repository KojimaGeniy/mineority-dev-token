pragma solidity ^0.4.23;
import "./MineorityMint.sol";

contract MineorityCore is MineorityMint {

    //**Main contract with all admin stuff**//
  
    constructor() public {
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;

        // It doesn't practically matters but for contract readability we should
        // call it in setter after deploying once, instead of here
        GPUPrice memory Mine_31Y1 = GPUPrice({
            GPUPrice:815,
            hostingPrice: 0
        });
        GPUPrice memory Mine_31Y2 = GPUPrice({
            GPUPrice:1030,
            hostingPrice: 0
        });
        GPUPrice memory Mine_31Y3 = GPUPrice({
            GPUPrice:1240,
            hostingPrice: 0
        });

        GPUPrice memory Mine_56Y2 = GPUPrice({
            GPUPrice:2500,
            hostingPrice: 0
        });
        GPUPrice memory Mine_56Y3 = GPUPrice({
            GPUPrice:3050,
            hostingPrice: 0
        });
        gpuClassToYearToPrice[1][1] = Mine_31Y1;
        gpuClassToYearToPrice[1][2] = Mine_31Y2;
        gpuClassToYearToPrice[1][3] = Mine_31Y3;
        gpuClassToYearToPrice[2][2] = Mine_56Y2;
        gpuClassToYearToPrice[2][3] = Mine_56Y3;
    }

    function() external payable {
        
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
