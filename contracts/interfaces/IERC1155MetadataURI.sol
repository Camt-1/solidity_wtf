// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./IERC1155.sol";

//ERC1155Metadata的可选接口,加入了uri()函数查询元数据
interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}