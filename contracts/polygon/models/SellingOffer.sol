//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../KittyInterface.sol";

contract SellingOffer is KittyInterface {
    function SellToCompositeKey(SellingOfferStructure memory _sellingOffer) private pure returns (string memory, string memory) {
        string[] memory attributes = new string[](3);

        attributes[0] = _sellingOffer.TokenSymbol;
        attributes[1] = addressToString(_sellingOffer.SAddress);
        attributes[2] = _sellingOffer.OrderId;

        return CreateCompositeKey(SellingOffersIndex, attributes);
    }

    function SellSaveState(SellingOfferStructure memory _sellingOffer) internal returns (string memory) {
      (string memory compositeKey, string memory err) = SellToCompositeKey(_sellingOffer);
        
        require( bytes(err).length == 0, 
                string(abi.encodePacked("unable to create a composite key:", err)) );

        SellingOfferData[compositeKey] = _sellingOffer;
        SellingIndexes.push(compositeKey);

        return "success";
    }

    // returns false if an Account object wasn't found in the SellingIndexes; otherwise returns true
    function SellLoadState(SellingOfferStructure memory _sellingOffer) internal view returns (bool, SellingOfferStructure memory) {
        uint len = SellingIndexes.length;

        (string memory compositeKey, string memory err) = SellToCompositeKey(_sellingOffer);
        
        require( bytes(err).length == 0, 
                string(abi.encodePacked("unable to create a composite key:", err)) );

        for (uint i = 0; i < len; i ++) {
            if (keccak256(abi.encodePacked(SellingOfferData[ compositeKey ].TokenSymbol)) == keccak256(abi.encodePacked( _sellingOffer.TokenSymbol ))
               && SellingOfferData[ compositeKey ].SAddress == _sellingOffer.SAddress) {
                return (true, SellingOfferData[ compositeKey ]);
            }
        }

        return (false, _sellingOffer);
    }

    function SellDeleteState(SellingOfferStructure memory _sellingOffer) internal {
        uint len = SellingIndexes.length;

        (string memory compositeKey, string memory err) = SellToCompositeKey(_sellingOffer);
        
        require( bytes(err).length == 0, 
                string(abi.encodePacked("unable to create a composite key:", err)) );

        for ( uint i = 0; i < len; i ++ ) {
            if (keccak256(abi.encodePacked(SellingOfferData[ compositeKey ].TokenSymbol)) == keccak256(abi.encodePacked( _sellingOffer.TokenSymbol ))
               && SellingOfferData[ compositeKey ].SAddress == _sellingOffer.SAddress) {
                delete compositeKey;
                break;
            }
        }
        
        delete SellingOfferData[compositeKey];
    }
}