pragma solidity ^0.4.23;

import "./TokenBase.sol";

contract TokenSale is TokenBase{

    //**Mint and burn tokens + put on sale**/

    function _mint(address _to, string _tokenId) public {
        require(_to != address(0));
        addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);

        //and put on sale
    }

    function _burn(address _owner, uint256 _tokenId) public {
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }

    function putOnSale(uint256 tokenId,uint256 price) public {
        //claim ownership to admin and make it on sale
    }
}
