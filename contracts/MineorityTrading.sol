pragma solidity ^0.4.23;
import "./MineorityOwnership.sol";

contract MineorityTrading is MineorityOwnership {

    // With potential to be expanded to fit user-trading system
    struct SaleLot {
        address seller;
        uint128 GPUClass;
        uint256 creationTime;
    }

    struct GPUPrice {
        uint256 GPUPrice;
        uint256 hostingPrice;
    }

    GPUPrice Mine_31Y1 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    GPUPrice Mine_31Y2 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    GPUPrice Mine_31Y3 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    
    GPUPrice Mine_56Y1 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    GPUPrice Mine_56Y2 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    GPUPrice Mine_56Y3 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    
    GPUPrice Mine_74Y1 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    GPUPrice Mine_74Y2 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    GPUPrice Mine_74Y3 = GPUPrice({
        GPUPrice:800,
        hostingPrice: 1200
    });
    

    uint128 rate; 

    mapping (uint256 => SaleLot) public tokenIndexToSaleLot;
    mapping (uint256 => uint256) public tokenIndexToHostingPeriod;
    mapping (uint256 => uint256) public tokenIndexToPurchaseDate;    

    event SaleCreated(uint256 tokenId,address seller,uint256 GPUClass);
    event SaleClosed(uint256 tokenId,address seller,uint256 GPUClass);
    event SaleCancelled(uint256 tokenId);
    
    // This will work for both admins and users(soon)
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

    function getPrice(uint256 _tokenId,uint256 _hostingPeriod,uint256 _GPUClass) public returns(uint256 price) {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];

        if(now < lot.creationTime + 1 years) {
            if(_GPUClass == 1) {
                price = (Mine_31Y1.GPUPrice + Mine_31Y1.hostingPrice) / rate;
            } else if(_GPUClass == 2) {
                price = (Mine_56Y1.GPUPrice + Mine_56Y1.hostingPrice) / rate;
            } else if(_GPUClass == 3) {
                price = (Mine_74Y1.GPUPrice + Mine_74Y1.hostingPrice) / rate;
            } 
        } else if(now < lot.creationTime + 2 years) {
            if(_GPUClass == 1) {
                price = (Mine_31Y2.GPUPrice + Mine_31Y2.hostingPrice) / rate;
            } else if(_GPUClass == 2) {
                price = (Mine_56Y2.GPUPrice + Mine_56Y2.hostingPrice) / rate;
            } else if(_GPUClass == 3) {
                price = (Mine_74Y2.GPUPrice + Mine_74Y2.hostingPrice) / rate;
            } 
        } else if(now < lot.creationTime + 3 years) {
            if(_GPUClass == 1) {
                price = (Mine_31Y3.GPUPrice + Mine_31Y3.hostingPrice) / rate;
            } else if(_GPUClass == 2) {
                price = (Mine_56Y3.GPUPrice + Mine_56Y3.hostingPrice) / rate;
            } else if(_GPUClass == 3) {
                price = (Mine_74Y3.GPUPrice + Mine_74Y3.hostingPrice) / rate;
            } 
        }

        return price;
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
