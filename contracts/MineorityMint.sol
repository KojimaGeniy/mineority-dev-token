pragma solidity ^0.4.23;
import "./MineorityTrading.sol";

contract MineorityMint is MineorityTrading{

    //**Mint and burn tokens**/
        
    //* Function to mint new token and immediately put it on sale
    // Requires sender to be admin
    function _mint(
        uint128 _asicID,
        uint256 _GPUType,
        uint256 _price) public /*ownerOnly*/
    {
        Token memory _token = Token({
            asicID: _asicID,
            tokenStatus: Status.New,
            GPUType: asicManufacturer(_GPUType)
        });

        uint256 _tokenId = allTokens.push(_token);
        addTokenTo(msg.sender,_tokenId);
        // Just to make sure
        require(_tokenId <= 4294967295);

        sellToken(_tokenId, _price);
    }

    function _burn(address _owner, uint256 _tokenId) public {
        require(msg.sender == _owner);
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }

    //* Functions to withdraw ours funds from fees

    //* Need another contract
    //* Ownership of contract functions/modifiers
    event Check(uint256 checksum);
    function proveOwner(uint256 _checksum) public {
        emit Check(_checksum);
    }
}
