// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./034ERC721.sol";

library ECDSA{
    //通过ECDSA,验证签名地址是否正确
    function verify(
        bytes32 _msgHash, //消息的hash
        bytes memory _signature, //签名
        address _signer //签名地址
    )
        internal
        pure
        returns (bool)
    {
        return recoverSigner(_msgHash, _signature) == _signer;
    }

    //从_msgHash和签名_signature中恢复signer地址
    function recoverSigner(
        bytes32 _msgHash,
        bytes memory _signature
    )
        internal
        pure
        returns (address)
    {
        //检查签名长度,65 是标准r,s,v签名的长度
        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        //用内联汇编来从签名中获得r,s,v的值
        assembly {
            /**
             * 前32 bytes存储签名的长度(动态数组存储规则)
             * add(sig, 32) = sig的指针 + 32
             * 等效为略过signature的前32 bytes
             * mload(p)载入从内存地址p起始的接下来32 bytes数据
             */

            //读取长度数据后的32 bytes
            r := mload(add(_signature, 0x20))
            //读取之后的32 bytes
            s := mload(add(_signature, 0x40))
            //读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
        //使用ecrecover(全局函数):利用msgHash和r,s,v恢复signer地址
        return ecrecover(_msgHash, v, r, s);
    }

    //返回以太坊签名消息
    //添加"\x19Ethereum Signed Message:\n32"字段，防止签名的是可执行交易
    function toEthSignedMessageHash(bytes32 hash)
        public
        pure
        returns (bytes32) 
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract SignatureNFT is ERC721 {
    address immutable public signer; //签名地址
    mapping(address => bool) public mintedAddress; //记录已经mint的地址

    constructor(string memory _name, string memory _symbol, address _signer)
        ERC721(_name, _symbol)
    {
        signer = _signer;
    }

    //利用ECDSA验证签名并mint
    function mint(address _account, uint256 _tokenId, bytes memory _signature)
        external
    {
        bytes32 _msgHash = getMessageHash(_account, _tokenId); //将_account和_tokenId打包消息
        bytes32 _ethSignedMessageHash = ECDSA.toEthSignedMessageHash(_msgHash); //计算以太坊签名消息
        require(verify(_ethSignedMessageHash, _signature), "Invalid signature"); //ECDSA检验通过
        require(!mintedAddress[_account], "Already minted!"); //地址没有mint过

        mintedAddress[_account] = true; //记录mint过的地址
        _mint(_account, _tokenId); //mint
    }

    //将mint地址和tokenId拼成msgHash
    function getMessageHash(
        address _account,
        uint256 _tokenId
    )
        public 
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    //ECDSA验证,调用ECDSA库的verify()函数
    function verify(bytes32 _msgHash, bytes memory _signature)
        public
        view
        returns (bool)
    {
        return ECDSA.verify(_msgHash, _signature, signer);
    }
}

contract VerifySignature {
    function getMessageHash(address _addr,uint256 _tokenId)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_addr, _tokenId));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address _signer,
        address _addr,
        uint _tokenId,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_addr, _tokenId);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }
    
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
        // implicitly return (r, s, v)
    }
}