pragma solidity ^0.4.23;
import "./MineorityOwnership.sol";

contract MineorityTrading is MineorityOwnership {

    struct SaleLot {
        address seller;
        uint128 GPUClass;
        uint256 creationTime;
    }

    struct GPUPrice {
        uint256 GPUPrice;
        uint256 hostingPrice;
    }

    //---STORAGE---//
    uint128 rate; 
    
    mapping(uint256 => mapping(uint256 => GPUPrice)) gpuClassToYearToPrice;

    mapping (uint256 => SaleLot) public tokenIndexToSaleLot;

    mapping (uint256 => uint256) public tokenIndexToHostingPeriod;
    
    mapping (uint256 => uint256) public tokenIndexToPurchaseDate;    

    event SaleCreated(uint256 tokenId,address seller,uint256 GPUClass);
    event SaleClosed(uint256 tokenId,address seller,uint256 GPUClass);
    event SaleCancelled(uint256 tokenId);
    

    function sellToken(uint256 _tokenId,uint256 _GPUClass) public whenNotPaused {
        clearApproval(msg.sender,_tokenId);
        removeTokenFrom(msg.sender,_tokenId);

        SaleLot memory lot = SaleLot({
            seller: msg.sender,
            GPUClass: uint128(_GPUClass),
            creationTime: now
        });

        tokenIndexToSaleLot[_tokenId] = lot;

        emit SaleCreated(_tokenId, msg.sender, _GPUClass);
    }

    function buyToken(uint256 _tokenId,uint256 _hostingPeriod) public payable whenNotPaused {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];

        uint256 price = getPrice(_tokenId,_hostingPeriod,lot.GPUClass);

        require(msg.value >= price);

        addTokenTo(msg.sender, _tokenId);
        //2% we will leave for ourselves
        lot.seller.transfer((price * 98)/100);

        delete tokenIndexToSaleLot[_tokenId];

        tokenIndexToHostingPeriod[_tokenId] = _hostingPeriod;
        tokenIndexToPurchaseDate[_tokenId] = now;

        emit SaleClosed(_tokenId,lot.seller,lot.GPUClass);
    }

    function getPrice(uint256 _tokenId,uint256 _hostingPeriod,uint256 _GPUClass) public view returns(uint256 price) {
        
        GPUPrice storage pricing = gpuClassToYearToPrice[_GPUClass][_hostingPeriod]; 

        return pricing.GPUPrice.add(pricing.hostingPrice);
    }

    function setPrice(uint256 _GPUClass,uint256 _hostingPeriod,uint256 _GPUPrice,uint256 _hostingPrice) public /*onlyCTO*/ {
        gpuClassToYearToPrice[_GPUClass][_hostingPeriod] = GPUPrice({
            GPUPrice: _GPUPrice,
            hostingPrice: _hostingPrice
        });
    }

    function removeSaleLot(uint256 _tokenId) public whenNotPaused {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];
        require(msg.sender == lot.seller);

        delete tokenIndexToSaleLot[_tokenId];
        addTokenTo(msg.sender, _tokenId);

        emit SaleCancelled(_tokenId);
    }

    function getSaleLot(uint256 _tokenId) public view returns (address,uint256,uint256) {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];

        return (
            lot.seller,
            lot.GPUClass,
            lot.creationTime );
    }
}
