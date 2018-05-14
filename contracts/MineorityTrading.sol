pragma solidity ^0.4.23;
import "./MineorityOwnership.sol";

contract MineorityTrading is MineorityOwnership {

    // With potential to be expanded to fit user-trading system
    struct SaleLot {
        address seller;
        uint128 price;
        //uint64 creationTime 
    }

    mapping (uint256 => SaleLot) public tokenIndexToSaleLot;

    event SaleCreated(uint256 tokenId,address seller,uint256 price);
    event SaleClosed(uint256 tokenId,address seller,uint256 price);
    event SaleCancelled(uint256 tokenId);
    
    // This will work for both admins and users(soon)
    function sellToken(uint256 _tokenId,uint256 _price) public {
        clearApproval(msg.sender,_tokenId);
        removeTokenFrom(msg.sender,_tokenId);

        //addTokenTo(this,tokenId);

        SaleLot memory lot = SaleLot({
            seller: msg.sender,
            price: uint128(_price)
        });

        tokenIndexToSaleLot[_tokenId] = lot;

        emit SaleCreated(_tokenId, msg.sender, _price);
    }

    function buyToken(uint256 _tokenId) public payable {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];

        require(msg.value >= lot.price,"Not enough wei");

        addTokenTo(msg.sender, _tokenId);
        delete tokenIndexToSaleLot[_tokenId];

        //* Do something with new arrived wei,
        //* take fees or whatever

        emit SaleClosed(_tokenId,lot.seller,lot.price);
    }


    function removeSaleLot(uint256 _tokenId) public {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];
        require(msg.sender == lot.seller);

        delete tokenIndexToSaleLot[_tokenId];
        addTokenTo(msg.sender, _tokenId);

        emit SaleCancelled(_tokenId);
    }

    function getSaleLot(uint256 _tokenId) public view returns (address,uint256) {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];

        return (
            lot.seller,
            lot.price );
    }
}
