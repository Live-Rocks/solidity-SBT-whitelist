// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract SoulBoundToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    bytes32 public root;
    address internal _owner;
    uint256 public tokenId = 0;

    Counters.Counter private _tokenIdCounter;

    mapping(address => bool) public hasMinted;

    constructor() ERC721("Supplier SBT", "SSBT") {
        _owner = msg.sender;
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://gateway.pinata.cloud/ipfs/QmUu6F2WYwh3bcij8LC4iAv4o4Tm4KnnpgMSebUBL1f7a1/";
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        _requireMinted(_tokenId);

        string memory baseURI = _baseURI();
        bytes memory uriBytes = abi.encodePacked(baseURI, _tokenId, ".json");
        return bytes(baseURI).length > 0 ? string(uriBytes) : "";
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == msg.sender || msg.sender == owner(),
            "You are not allowed to burn this token."
        );
        _burn(_tokenId);
    }

    //SBT

    function transferFrom(
        address from,
        address to,
        uint256 _tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: caller is not token owner or approved"
        );
        super._transfer(from, to, _tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 _tokenId
    ) public override {
        require(
            msg.sender == owner(),
            "Only contract owner can transfer tokens"
        );
        require(_tokenId != 0, "Supplier SBT cannot be transferred.");
        super.safeTransferFrom(from, to, _tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 _tokenId,
        bytes memory data
    ) public override {
        require(
            msg.sender == owner(),
            "Only contract owner can transfer tokens"
        );
        require(_tokenId != 0, "Supplier SBT cannot be transferred.");
        super.safeTransferFrom(from, to, _tokenId, data);
    }

    //whitelist

    modifier verifyProof(bytes32[] memory proof) {
        require(
            MerkleProof.verify(
                proof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Invalid proof"
        );
        _;
    }

    function whitelistMint(
        bytes32[] calldata _proof
    ) external verifyProof(_proof) {
        require(!hasMinted[msg.sender], "You have already minted a token");
        tokenId++;
        _safeMint(msg.sender, tokenId);
        hasMinted[msg.sender] = true;
    }

    function verify(bytes32[] memory proof) external view returns (bool) {
        return
            MerkleProof.verify(
                proof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            );
    }

    function setRoot(bytes32 _root) external {
        require(_owner == msg.sender, "Only owner can set root");
        root = _root;
    }
}
