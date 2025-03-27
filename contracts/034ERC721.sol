// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./interface/IERC165.sol";
import "./interface/IERC721.sol";
import "./interface/IERC721Metadata.sol";
import "./interface/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERC721 is IERC721, IERC721Metadata {
    using Strings for uint256;

    string public override name;
    string public override symbol;
    mapping(uint => address) private _owners;
    mapping(address => uint) private _balances;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    error ERC721InvalidReceiver(address receiver);

    constructor (string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function balanceOf(address owner) external view override returns (uint)
    {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view override returns (address owner)
    {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    } 

    function isApprovedForAll(address owner,address operator) external view override returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator, bool approved) external override
    {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) external view override returns (address)
    {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    function _approve(
        address owner,
        address operator,
        uint256 tokenId
    )
        private
    {
        _tokenApprovals[tokenId] = operator;
        emit Approval(owner, operator, tokenId);
    }

    function approve(
        address operator,
        uint256 tokenId
    )
        external
        override
    {
        address owner = ownerOf(tokenId);
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, operator, tokenId);
    }

    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    )
        private
        view
        returns (bool)
    {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }

    function _transfer(
        address owner,
        address sender,
        address recipient,
        uint tokenId
    )
        private
    {
        require(sender == owner, "not owner");
        require(recipient != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[sender] -= 1;
        _balances[recipient] += 1;
        _owners[tokenId] = recipient;

        emit Transfer(sender, recipient, tokenId);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint tokenId
    )
        external
        override
    {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, sender, recipient, tokenId);
    }

    function _safeTransfer(
        address owner,
        address sender,
        address recipient,
        uint tokenId,
        bytes memory _data
    )
        private
    {
        _transfer(owner, sender, recipient, tokenId);
        _checkOnERC721Received(sender, recipient, tokenId, _data);
    }

    function safeTransferFrom(
        address sender,
        address recipient,
        uint tokenId,
        bytes memory _data
    )
        public
        override
    {
        address owner = ownerOf[tokenId];
        require(
            _isApprovedOrOwner(owner, sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, sender, recipient, tokenId, _data);
    }

    function safeTransferFrom(
        address sender,
        address recipient,
        uint tokenId
    )
        external
        override
    {
        safeTransferFrom(sender, recipient, tokenId);
    }

    function _mint(address recipient, uint tokenId) internal virtual {
        require(recipient != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[recipient] += 1;
        _owners[tokenId] = recipient;

        emit Transfer(address(0), recipient, tokenId);
    }

    function _burn(address sender, uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(sender, address(0), tokenId);
    }

    function _checkOnERC721Received(
        address sender,
        address recipient,
        uint256 tokenId,
        bytes memory data
    )
        private
    {
        if (recipient.code.length > 0) {
            try IERC721Receiver(recipient).onERC721Received(msg.sender, sender, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(recipient);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(recipient);
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI), tokenId.toString()) : "";
    }

    //计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}