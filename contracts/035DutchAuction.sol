// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./034ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTION_SIZE = 10000; //NFT总数
    uint256 public constant AUCTION_START_PRICE = 1 ether; //起拍价
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; //最低价
    uint256 public constant AUCTION_TIME = 10 minutes; //拍卖时间
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; //每过多次时间,价格衰减
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); //设置价格衰减步长

    uint256 public auctionStartTime; //拍卖开始时间戳
    string private _baseTokenURI; //metadata URI
    uint256[] private _allTokens; //记录所有存在的tokenID

    constructor() Ownable(msg.sender) ERC721("Camt_Dutch_Auction", "Camt") {
        auctionStartTime = block.timestamp;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    //添加一个新的token
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    //拍卖mint函数
    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime); //建立local变量,减少gas花费
        //检查是否设置拍卖事件,拍卖是否开始
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not started yet"
        );
        //检查是否超过NFT上限
        require(
            totalSupply() + quantity <= COLLECTION_SIZE,
            "not enough remaining reserved for auction to support desired mint amount"
        );

        uint256 totalCost = getAuctionPrice() * quantity; //计算mint成本
        require(msg.value >= totalCost, "Need to send more ETH."); //检查用户是否支付足够ETH

        //Mint NFT
        for (uint256 i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        //多余ETH退款
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    //获取拍卖实时价格
    function getAuctionPrice()
        public
        view
        returns (uint256)
    {
        if (block.timestamp < auctionStartTime) {
            return AUCTION_START_PRICE;
        } else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
            return AUCTION_END_PRICE;
        } else {
            uint256 steps = (block.timestamp - auctionStartTime) / AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}