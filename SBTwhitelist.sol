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
            "https://ipfs.io/ipfs/QmRxA1isnc4wVz1ezR2uyM661migYk8Ny3nVo6gkKUs3ZF/";
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == msg.sender || msg.sender == owner(),
            "You are not allowed to burn this token."
        );
        _burn(_tokenId);
    }

    //SBT

    function _beforeTokenTransfer(address from, address to, uint256) internal {
        require(
            from == address(0) || to == address(0),
            "This a Soulbound token. It cannot be transferred. "
            "It can only be burned by the token owner."
        );
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
