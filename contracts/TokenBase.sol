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

    bytes4 constant InterfaceSignature_ERC165 = 0x01ffc9a7;
    /*
    bytes4(keccak256('supportsInterface(bytes4)'));
    */

    bytes4 constant InterfaceSignature_ERC721Enumerable = 0x780e9d63;
    /*
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
    bytes4(keccak256('tokenByIndex(uint256)'));
    */

    bytes4 constant InterfaceSignature_ERC721 = 0x80ac58cd;
    /*
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('getApproved(uint256)')) ^
    bytes4(keccak256('setApprovalForAll(address,bool)')) ^
    bytes4(keccak256('isApprovedForAll(address,address)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
    bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'));
    */

    bytes4 public constant InterfaceSignature_ERC721Optional =- 0x4f558e79;
    /*
    bytes4(keccak256('exists(uint256)'));
    */

    //---MODIFIERS---//
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }
    //---ERC721 IMPLEMENTATION--//
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165)
            || (_interfaceID == InterfaceSignature_ERC721)
            || (_interfaceID == InterfaceSignature_ERC721Enumerable));
    }

    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }
    function balanceOf(address _owner) public view returns (uint256 count) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner) {
        owner = tokenIndexToOwner[_tokenId];
        require(owner != address(0));
    }
    //Consider it optional, test for necessarity
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
        emit ApprovalForAll(msg.sender, _to, _approved);
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


    function tokenInfo(uint256 _tokenId) public returns (token) {
        //return relevant token Info by ID
    }
}
