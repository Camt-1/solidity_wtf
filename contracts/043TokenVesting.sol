// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./031ERC20.sol";
//event
//`ERC20Released`提币事件,当受益人提取释放代币时释放

//state variables
//- `beneficiary`受益人地址
//- `start`归属期起始时间戳
//- `duration`归属期,单位为秒
//- `erc20Released`代币地址->释放数量的映射,记录受益人已领取的代币数量

//function
//- `constructor`初始化受益人地址,归属期,起始时间戳. 参数为受益人地址和归属期.
//- `release()`提取代币函数,将已释放的代币转账给受益人.调用`vestedAmount()`函数计算可提取的代币,
//释放`ERC20Released事件,然后将代币tranfer给受益人. 参数为代币地址token.
//- `vestedAmount()`根据线性释放公式,查询已经释放的代币数量.开发者可以通过修改这个函数,自定义释放方式.
//参数为代币地址token和查询时时间戳timestamp

contract TokenVesting {
    event ERC20Released(address indexed beneficiary, uint256 amount);

    address public immutable beneficiary;
    uint256 public immutable start;
    uint256 public immutable duration;
    mapping(address => uint256) public erc20Released;

    constructor (address _beneficiary, uint256 _duration) {
        require(_beneficiary != address(0), "beneficiary is zero address");
        beneficiary = _beneficiary;
        start = block.timestamp;
        duration = _duration;
    }

    function release(address token) public {
        uint256 releasable = vestedAmount(token, uint256(block.timestamp)) - erc20Released[token];
        erc20Released[token] += releasable;
        emit ERC20Released(beneficiary, releasable);
        IERC20(token).transfer(beneficiary, releasable);
    }

    function vestedAmount(address token, uint256 timestamp) public view returns (uint256) {
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return ((timestamp - start) / duration) * totalAllocation;
        }
    }
}