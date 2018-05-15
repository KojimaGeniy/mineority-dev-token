pragma solidity ^0.4.23;
import "./MineorityAccessControl.sol";
import "./ERC721Receiver.sol";
import "./utils/SafeMath.sol";
import "./utils/AddressUtils.sol";

contract MineorityBase is MineorityAccessControl {
    using SafeMath for uint256;
    using AddressUtils for address;

    //**ERC721 implementation + all data structures**//
    enum asicManufacturer {AMD, NVIDIA, Intel}

    struct Token {
        //The memory type of a GPU card - in this case, the part number. Always 11 characters in length.
        string memInfo;
        //The unique ASIC Serial ID of a GPU card. It is stored as a binary value.
        uint128 asicID;
        //The unique PCI Vendor ID of a GPU card. It is stored as a binary value.
        uint16 pciVendorID;
        //The unique PCI Device ID of a GPU card. It is stored as a binary value.
        uint16 pciDeviceID;
        //The model name and number of a GPU card.
        uint16 pciSubDeviceID;
        //The manufacturer of a GPU card - for instance, ASUS.
        uint16 pciSubVendorID;
        //The memory size of a GPU card - for instance, 16384 MB. Stored as a binary value.
        uint16 memSizeMB;
        //The manufacturer of a GPU ASIC.  This has only three possible value stores. 
        asicManufacturer GPUType;
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

    //* Same with them, hashing functions mentioned in ERC721.sol
    bytes4 constant InterfaceSignature_ERC721Enumerable = 0x780e9d63;
    bytes4 public constant InterfaceSignature_ERC721Optional =- 0x4f558e79;


    //* Interal function to check if target address is a regular address
    // or an applicable to recieve token contract
    function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }
}
