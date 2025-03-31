// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./031ERC20.sol";
import "./interfaces/IERC20.sol";

//event
//`TokenLockStart`锁仓开始事件,在合约部署时释放,记录受益人地址,代币地址,锁仓起始时间,和结束时间
//`Release`代币释放事件,在受益人取出代币时释放,记录受益人地址,代币地址,释放代币时间,和代币数量

//state variables
//`token`锁仓代币地址
//`beneficiary`受益人地址
//`lockTime`锁仓时间
//`startTime`锁仓起始时间戳

//function
//`constructor`初始化代币合约,受益人地址,以及锁仓时间
//`release()`在锁仓期满后,将代币释放给受益人.需要受益人主动调用release()函数提取代币

contract TokenLock {
    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 timestamp, uint256 amount);

    IERC20 public immutable token;
    address public immutable beneficiary;
    uint256 public immutable lockTime;
    uint256 public immutable startTime;

    constructor (address _beneficiary, IERC20 _token, uint256 _lockTime) {
        require(_beneficiary != address(0), "beneficiary is zero address");
        beneficiary = _beneficiary;
        token = _token;
        lockTime = _lockTime;
        startTime = block.timestamp;

        emit TokenLockStart(_beneficiary, address(token), block.timestamp, _lockTime);
    }

    function release() public {
        require(block.timestamp >= startTime+lockTime, "current time is before release time");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "no tokens to release");

        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }
}