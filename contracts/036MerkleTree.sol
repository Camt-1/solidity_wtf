// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./034ERC721.sol";

library MerkleProof {
    //当通过`proof`和`leaf`重建出的`root`与给定的`root`相等时,返回`true`,数据有效
    //在重建时,叶子节点对和元素对都是排序过的
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool)
    {
        return processProof(proof, leaf) == root;
    }

    //Returns通过Merkle树用`leaf`和`proof`计算出`root`,当重建出的`root`和给定的`root`相同时,`proof`才是有效的
    //在重建时,叶子节点对和元素对都是排序过的
    function processProof(
        bytes32[] memory proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    //Sorted Pair Hash
    function _hashPair(
        bytes32 a,
        bytes32 b
    ) private pure returns (bytes32)
    {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

contract MerkleTree is ERC721 {
    bytes32 immutable public root; //Merkle树的根
    mapping(address => bool) public mintedAddress; //记录已经mint的地址

    constructor(string memory name, string memory symbol, bytes32 merkleroot)
        ERC721(name, symbol)
    {
        root = merkleroot;
    }

    //利用Merkle树验证地址并mint
    function mint(address account, uint256 tokenId, bytes32[] calldata proof)
        external
    {
        require(_verify(_leaf(account), proof), "Invalid merkle proof"); //Merkle验证通过
        require(!mintedAddress[account], "Already minted!"); //地址没有mint过

        mintedAddress[account] = true; //记录mint过的地址
        _mint(account, tokenId); //mint
    }

    //计算Merkle叶子的哈希值
    function _leaf(address account)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(account));
    }

    //Merkle树验证,调用MerkleProof库的verify()函数
    function _verify(bytes32 leaf, bytes32[] memory proof)
        internal
        view
        returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }
}