pragma solidity ^0.4.23;

contract ERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;  
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function approve(address _to, uint256 _tokenId) public;
    function setApprovalForAll(address _operator, bool _approved) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
    
    //ERC721 Enumerable
    function totalSupply() public view returns (uint256 total);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256);
    
    //Optional extension
    function exists(uint256 _tokenId) public view returns (bool _exists);
}
