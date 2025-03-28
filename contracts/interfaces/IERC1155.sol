// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./IERC165.sol";

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values  
    );
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event URI(
        string value,
        uint256 indexed id
    );

    //持仓查询,返回`account`拥有的`id`种类的代币持仓量
    function balanceOf(address account, uint256 id) external view returns (uint256);

    //批量持仓查询,`accounts`和`ids`数组的长度要相等
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    //批量授权,将调用者的代币授权给`operator`地址
    function setApprovalForAll(address operator, bool approved) external;

    //批量授权查询,如果授权地址`operator`被`account`授权,则返回`true`
    function isApprovedForAll(address account, address operator) external view returns (bool);

    //安全转账,将`amount`单位`id`种类的代币从`from`转账给`to`,释放TransferSingle时间
    //要求:
    //- 如果调用者不是`from`地址而是授权地址,则需要得到`from`的授权
    //- `from`地址必须有足够的持仓
    //- 如果接收方是合约,需要实现`IERC1155Receiver`和`onERC1155Received`方法,并返回相应的值
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    //批量安全操作,释放TransferBatch事件
    //要求:
    //- `ids`和`amounts`长度相等
    //- 如果接收方是合约, 需要实现`IERC1155Receiver`的`onERC1155Batchreceived`方法,并返回相应的值
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}