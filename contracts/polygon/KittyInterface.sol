//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./Structures.sol";
import "./Consts.sol";

contract KittyInterface is Consts, Structures {
    mapping (string => BuyingOfferStructure) public BuyingOfferData;
    mapping (string => FractionaliseStructure) public FractionaliseData;
    mapping (string => FractionaliseStreamingStructure) public FractionaliseStreamingData;
    mapping (string => SellingOfferStructure) public SellingOfferData;
    string[] BuyingIndexes;
    string[] SellingIndexes;
    string[] FractionaliseIndexes;
    string[] FStreamingIndexes;

    //modifier to check the owner
    modifier onlyOwnerOf(address _address) {
        require(msg.sender == _address);
        _;
    }
    
    // this is mock for CreateCompositeKey of Hyperledger
    function CreateCompositeKey(string memory _objectType, string[] memory _attributes) internal virtual pure returns (string memory, string memory) {
        uint len = _attributes.length;
        string memory result = _objectType;

        for (uint i = 0; i < len; i ++) {
            result = string(abi.encodePacked(result, _attributes[i]) );
        }
        return (result, "");
    }

    function addressToString(address _address) public pure returns(string memory) {
       bytes32 _bytes = bytes32(uint256(uint160(_address)));
       bytes memory HEX = "0123456789abcdef";
       bytes memory _string = new bytes(42);
    
       _string[0] = '0';
       _string[1] = 'x';
     
       for(uint i = 0; i < 20; i++) {
           _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
           _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
       }
    
       return string(_string);
    }
}