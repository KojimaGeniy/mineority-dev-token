pragma solidity ^0.4.23;
import "./MineorityOwnership.sol";

contract MineorityTrading is MineorityOwnership {

    struct SaleLot {
        address seller;
        uint16 GPUClass;
        uint256 creationTime;
    }

    struct GPUPrice {
        uint128 GPUPrice;
        uint128 hostingPrice;
    }

    //---STORAGE---//
    uint128 public rate; 
    
    mapping (uint256 => mapping(uint256 => GPUPrice)) internal gpuClassToYearToPrice;

    mapping (uint256 => SaleLot) public tokenIndexToSaleLot;

    mapping (uint256 => uint256) public tokenIndexToHostingPeriod;
    
    mapping (uint256 => uint256) public tokenIndexToPurchaseDate;

    mapping (uint256 => uint128) public tokenIndexToPurchasePrice;

    event SaleCreated(uint256 tokenId,address seller,uint256 GPUClass);
    event SaleClosed(uint256 tokenId,address seller,uint256 GPUClass);
    event SaleCancelled(uint256 tokenId);
    

    function sellToken(uint256 _tokenId,uint256 _GPUClass) public whenNotPaused {
        clearApproval(msg.sender,_tokenId);
        removeTokenFrom(msg.sender,_tokenId);

        SaleLot memory lot = SaleLot({
            seller: msg.sender,
            GPUClass: uint16(_GPUClass),
            creationTime: now
        });

        tokenIndexToSaleLot[_tokenId] = lot;

        emit SaleCreated(_tokenId, msg.sender, _GPUClass);
    }

    function buyTokens(uint256[] _tokenIds,uint256[] _hostingPeriods) public payable whenNotPaused {
        uint256 price = 0;

        for(uint16 i = 0;i < _tokenIds.length;i++) {
            SaleLot storage lot = tokenIndexToSaleLot[_tokenIds[i]];

            require(tokenIndexToSaleLot[_tokenIds[i]].seller != address(0));

            price = price.add(getPrice(tokenIndexToSaleLot[_tokenIds[i]].GPUClass,_hostingPeriods[i]).mul(1 ether)/rate);

            require(getPrice(tokenIndexToSaleLot[_tokenIds[i]].GPUClass,_hostingPeriods[i]) != 0);        
            require(msg.value >= price);
            
            addTokenTo(msg.sender, _tokenIds[i]);

            //lot.seller.transfer((price * 98)/100);

            delete tokenIndexToSaleLot[_tokenIds[i]];

            tokenIndexToHostingPeriod[_tokenIds[i]] = now.add(_hostingPeriods[i]);
            tokenIndexToPurchaseDate[_tokenIds[i]] = now;
            tokenIndexToPurchasePrice[_tokenIds[i]] = uint128(price);
            

            emit SaleClosed(_tokenIds[i],lot.seller,lot.GPUClass);
        }
    }

    function buyToken(uint256 _tokenId,uint256 _hostingPeriod) public payable whenNotPaused {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];        
        
        require(tokenIndexToSaleLot[_tokenId].seller != address(0));
        uint256 price = getPrice(tokenIndexToSaleLot[_tokenId].GPUClass,_hostingPeriod);

        price = price.mul(1 ether)/rate;
        require(price != 0);
        require(msg.value >= price);

        addTokenTo(msg.sender, _tokenId);
        //2% we will leave for ourselves
        //lot.seller.transfer((price * 98)/100);

        delete tokenIndexToSaleLot[_tokenId];

        tokenIndexToHostingPeriod[_tokenId] = now.add(_hostingPeriod);
        tokenIndexToPurchaseDate[_tokenId] = now;
        tokenIndexToPurchasePrice[_tokenId] = uint128(price);

        emit SaleClosed(_tokenId,lot.seller,lot.GPUClass);
    }

    //* Returns price for any particular GPU with hosting price
    function getPrice(uint256 _GPUClass,uint256 _hostingPeriod) public view returns(uint256 price) {
        
        uint128 gpuPrice = gpuClassToYearToPrice[_GPUClass][_hostingPeriod].GPUPrice; 
        uint128 hostPrice = gpuClassToYearToPrice[_GPUClass][_hostingPeriod].hostingPrice;
        
        uint256 priceT = uint256(gpuPrice.add(hostPrice));
        return priceT;
    }

    //* Setter for price of every available GPU, only for CTO
    function setPrice(uint256 _GPUClass,uint256 _hostingPeriod,uint256 _GPUPrice,uint256 _hostingPrice) public onlyCTO {
        gpuClassToYearToPrice[_GPUClass][_hostingPeriod] = GPUPrice({
            GPUPrice: uint128(_GPUPrice),
            hostingPrice: uint128(_hostingPrice)
        });
    }

    function setRate(uint256 _newRate) public onlyCTO {
        rate = uint128(_newRate);
    } 

    //* Removes token from sale, requires sender to be seller
    function removeSaleLot(uint256 _tokenId) public whenNotPaused {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];
        require(msg.sender == lot.seller);

        delete tokenIndexToSaleLot[_tokenId];
        addTokenTo(msg.sender, _tokenId);

        emit SaleCancelled(_tokenId);
    }

    //* Returns all information about chosen by tokenID Sale lot
    function getSaleLot(uint256 _tokenId) public view returns (address,uint256,uint256) {
        SaleLot storage lot = tokenIndexToSaleLot[_tokenId];

        return (
            lot.seller,
            lot.GPUClass,
            lot.creationTime );
    }
}