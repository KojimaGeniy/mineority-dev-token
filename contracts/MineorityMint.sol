pragma solidity ^0.4.23;
import "./MineorityTrading.sol";
import "./utils/strings.sol";

contract MineorityMint is MineorityTrading{
    using strings for *;

    //**Mint and burn tokens**/
        
    //* Function to mint new token and immediately put it on sale
    // Requires sender to be CTO address
    function _mint(
        uint256 _asicID,
        uint256 _pciVendorID,
        uint256 _pciDeviceID,
        uint256 _pciSubDeviceID,
        uint256 _pciSubVendorID,
        uint256 _memSizeMB,
        string _memInfo,
        uint256 _GPUType,
        uint256 _GPUClass) public onlyCTO
    {
        Token memory _token = Token({
            asicID: uint128(_asicID),
            pciVendorID: uint16(_pciVendorID),
            pciDeviceID: uint16(_pciDeviceID),
            pciSubDeviceID: uint16(_pciSubDeviceID),
            pciSubVendorID: uint16(_pciSubVendorID),
            memSizeMB: uint16(_memSizeMB),
            memInfo: _memInfo,
            GPUType: asicManufacturer(_GPUType)
        });

        uint256 _tokenId = allTokens.length;
        allTokens.push(_token); 

        addTokenTo(msg.sender,_tokenId);
        // Just to make sure
        require(_tokenId <= 4294967295);

        sellToken(_tokenId, _GPUClass);
    }

    //* Burns token in case when user wants his GPU to be shipped
    // Requires sender to be owner of token
    function _burn(address _owner, uint256 _tokenId) public onlyCTO {
        require(msg.sender == _owner);
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }
}
