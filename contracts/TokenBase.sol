pragma solidity ^0.4.23;
import "./ERC721.sol";
import "./ERC721Receiver.sol";
import "./utils/SafeMath.sol";
import "./utils/AddressUtils.sol";

contract TokenBase is ERC721 {
    using SafeMath for uint256;
    using AddressUtils for address;

    //**ERC721 implementation + all data structures**//

    enum Status {New,Active,Maintenance,Unmounted}
    enum Type {AMD, Nvidia}

    struct Token {
        string GPUID;
        Status tokenStatus;
        Type GPUType;
    }

    //---STORAGE---//
    Token[] internal allTokens;  

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba; 

    mapping (uint256 => address) internal tokenIndexToOwner;

    mapping (uint256 => address) internal tokenIndexToApproved;

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
        require(isApprovedOrOwner(msg.sender, _tokenId),"You are not authorized to transfer this token.");
        _;
    }
    //---ERC721 IMPLEMENTATION---//
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool)
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
    //Consider it useless, test for necessarity
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenIndexToOwner[_tokenId];
        return owner != address(0);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    function transferFrom(address _from,address _to,uint256 _tokenId) public canTransfer(_tokenId) {
        require(_from != address(0));
        require(_to != address(0));

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _to,uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        if (getApproved(_tokenId) != address(0) || _to != address(0)) {
            tokenIndexToApproved[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenIndexToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }
    //---ERC721 ENUMERATION IMPLEMENTATION---//
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    function tokenByIndex(uint256 _index) public view returns (uint,uint) {
        require(_index < totalSupply());
        return (uint(allTokens[_index].tokenStatus),uint(allTokens[_index].GPUType));
    }

    //------//
    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(tokenIndexToOwner[_tokenId] == address(0));
        tokenIndexToOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from,"Specified user is not token owner.");
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenIndexToOwner[_tokenId] = address(0);
    }

    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner,"Specified user is not token owner.");
        if (tokenIndexToApproved[_tokenId] != address(0)) {
            tokenIndexToApproved[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
    }

    function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }


    // function tokenInfo(uint256 _tokenId) public returns (Status,Type) {
    //     return(
    //         allToken fields here
    //     )
    // }
}
