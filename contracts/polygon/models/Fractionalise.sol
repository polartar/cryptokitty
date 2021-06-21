//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../KittyInterface.sol";

contract Fractionalise is KittyInterface {
    function FSaveState(FractionaliseStructure memory _fractionalise) internal returns (string memory) {
        FractionaliseData[_fractionalise.TokenSymbol] = _fractionalise;
        FractionaliseIndexes.push(_fractionalise.TokenSymbol);

        return "success";
    }

    // returns false if an Account object wasn't found in the FractionaliseIndexes; otherwise returns true
    function FLoadState(FractionaliseStructure memory _fractionalise) internal view returns (bool, FractionaliseStructure memory) {
        uint len = FractionaliseIndexes.length;

        for (uint i = 0; i < len; i ++) {
            if (keccak256(abi.encodePacked( FractionaliseData[FractionaliseIndexes[i]].TokenSymbol )) == keccak256(abi.encodePacked( _fractionalise.TokenSymbol ))) {
                return (true, FractionaliseData[ FractionaliseIndexes[i] ]);
            }
        }

        return (false, _fractionalise);
    }

    function FDeleteState(FractionaliseStructure memory _fractionalise) internal {
        uint len = FractionaliseIndexes.length;

        for ( uint i = 0; i < len; i ++ ) {
            if (keccak256(abi.encodePacked( FractionaliseData[FractionaliseIndexes[i]].TokenSymbol )) == keccak256(abi.encodePacked( _fractionalise.TokenSymbol ))) {
                delete FractionaliseIndexes[i];
                break;
            }
        }
        
        delete FractionaliseData[_fractionalise.TokenSymbol];
    }
}