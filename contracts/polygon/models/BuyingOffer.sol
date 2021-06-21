//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "../KittyInterface.sol";

contract BuyingOffer is KittyInterface {
    function BuyToCompositeKey( BuyingOfferStructure memory _buyingOffer) private pure returns (string memory, string memory) {
        string[] memory attributes = new string[](3);
        
        attributes[0] = _buyingOffer.TokenSymbol;
        attributes[1] = addressToString(_buyingOffer.BAddress);
        attributes[2] = _buyingOffer.OrderId;

        return CreateCompositeKey(BuyingOffersIndex, attributes);
    }

    // save the offer to BuyingOfferData mapping
    function BuySaveState(BuyingOfferStructure memory _buyingOffer) internal returns (string memory) {
        (string memory compositeKey, string memory err) = BuyToCompositeKey(_buyingOffer);
        
        require( bytes(err).length == 0, 
                string(abi.encodePacked("unable to create a composite key:", err)) );

        BuyingOfferData[compositeKey] = _buyingOffer;
        BuyingIndexes.push(compositeKey);
 
        return "success";
    }

    // returns false if an Account object wasn't found in the BuyingIndexes; otherwise returns true
    function BuyLoadState(BuyingOfferStructure memory _buyingOffer) internal view returns (bool, BuyingOfferStructure memory) {
        uint len = BuyingIndexes.length;

        (string memory compositeKey, string memory err) = BuyToCompositeKey(_buyingOffer);
        
        require( bytes(err).length == 0, 
                string(abi.encodePacked("unable to create a composite key:", err)) );

         for (uint i = 0; i < len; i ++) {
            if ( keccak256(abi.encodePacked(BuyingOfferData[ compositeKey ].TokenSymbol)) == keccak256(abi.encodePacked( _buyingOffer.TokenSymbol )) 
                 && BuyingOfferData [compositeKey].BAddress == _buyingOffer.BAddress) {
                return (true, BuyingOfferData[ compositeKey ]);
            }
        }

        return (false, _buyingOffer);
    }

    function BuyDeleteState(BuyingOfferStructure memory _buyingOffer) internal {
        uint len = BuyingIndexes.length;

        (string memory compositeKey, string memory err) = BuyToCompositeKey(_buyingOffer);
        
        require( bytes(err).length == 0, 
                string(abi.encodePacked("unable to create a composite key:", err)) );

        for ( uint i = 0; i < len; i ++ ) {
            if ( keccak256(abi.encodePacked(BuyingOfferData[ compositeKey ].TokenSymbol)) == keccak256(abi.encodePacked( _buyingOffer.TokenSymbol )) 
                 && BuyingOfferData [compositeKey].BAddress == _buyingOffer.BAddress) {
                delete compositeKey;
                break;
            }
        }

        delete BuyingOfferData[compositeKey];
    }
}