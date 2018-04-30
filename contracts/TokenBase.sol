pragma solidity ^0.4.23;
import "./ERC721.sol";

contract TokenBase is ERC721 {

    //**ERC721 implementation + all data structures**//

    string public name;
    string public symbol;
    enum Status {New,Active,Maintenance,Unmounted}
    enum Type {AMD, Nvidia}

    struct token {
        Status tokenStatus;
        Type GPUType;
    }

    //---STORAGE---//
    token[] internal allTokens;  

    mapping (address => uint256) internal ownedTokensCount;

    mapping (address => uint256[]) internal ownedTokens;

    mapping (address => mapping (address => bool)) internal operatorApprovals;

    //---EVENTS---//
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    //---MODIFIERS---//
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }
    //---ERC721 IMPLEMENTATION--//
    function implementsERC721() public pure returns (bool) {
        return true;
    }

    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        owner = tokenIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

    function approve(address _to,uint256 _tokenId) public {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));
        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);
        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from,address _to,uint256 _tokenId) public canTransfer(_tokenId) {
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        return allTokens[_index];
    }

    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        ApprovalForAll(msg.sender, _to, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }


    function tokenInfo(uint256 _tokenId) public returns (token) {
        //return relevant token Info by ID
    }
}
