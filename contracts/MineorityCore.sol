pragma solidity ^0.4.23;
import "./TokenSale.sol";

contract TokenCore is TokenSale {

    //**Main contract with all admin stuff**//
  
    constructor() public {
      // constructor
    }

    function() external payable {
        require(
          //msg.sender == address of some of our contracts
        );
    }
}
