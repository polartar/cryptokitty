//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../KittyInterface.sol";

contract FractionaliseStreaming is KittyInterface {
    function FSSaveState(FractionaliseStreamingStructure memory _fStreaming) internal returns (string memory) {
        FractionaliseStreamingData[_fStreaming.TokenSymbol] = _fStreaming;
        FStreamingIndexes.push(_fStreaming.TokenSymbol);

        return "success";
    }

    // returns false if an Account object wasn't found in the FStreamingIndexes; otherwise returns true
    function FSLoadState(FractionaliseStreamingStructure memory _fStreaming) internal view returns (bool, FractionaliseStreamingStructure memory) {
        uint len = FStreamingIndexes.length;

        for (uint i = 0; i < len; i ++) {
            if (keccak256(abi.encodePacked( FractionaliseStreamingData[FStreamingIndexes[i]].TokenSymbol )) == keccak256(abi.encodePacked( _fStreaming.TokenSymbol ))) {
                return (true, FractionaliseStreamingData [ FStreamingIndexes[i] ]);
            }
        }

        return (false, _fStreaming);
    }

    function FSDeleteState(FractionaliseStreamingStructure memory _fStreaming) internal {
        uint len = FStreamingIndexes.length;

        for ( uint i = 0; i < len; i ++ ) {
            if (keccak256(abi.encodePacked( FractionaliseStreamingData[FStreamingIndexes[i]].TokenSymbol )) == keccak256(abi.encodePacked( _fStreaming.TokenSymbol ))) {
                delete FStreamingIndexes[i];
                break;
            }
        }

        delete FractionaliseStreamingData[_fStreaming.TokenSymbol];
    }
}