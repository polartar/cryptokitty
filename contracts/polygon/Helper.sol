//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./models/BuyingOffer.sol";
import "./models/Fractionalise.sol";
import "./models/FractionaliseStreaming.sol";
import "./models/SellingOffer.sol";

contract Helper is BuyingOffer, Fractionalise, FractionaliseStreaming, SellingOffer{
    struct OutputStructure {
        FractionaliseStructure[] UpdateFractionalise;
        BuyingOfferStructure[]  UpdateBuyingOffers;
        SellingOfferStructure[] UpdateSellingOffers;
        TransferStructure[] Transactions;
    }

    /* -------------------------------------------------------------------------------------------------
    This is mock of sub.getTxId(now this generates random number)
    ------------------------------------------------------------------------------------------------- */
    function GetTxID() internal view returns(string memory) {
        return uint2str(uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp))));
    }

   function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    /* -------------------------------------------------------------------------------------------------
    registerSellingOffer: this function registers a selling offer on blockchain
    ------------------------------------------------------------------------------------------------- */
    function registerSellingOffer(SellingOfferStructure memory _sellingOffer) internal{
        SellSaveState(_sellingOffer);
    }

    /* -------------------------------------------------------------------------------------------------
    registerBuyingOffer: this function registers a buying offer on blockchain
    ------------------------------------------------------------------------------------------------- */
    function registerBuyingOffer(BuyingOfferStructure memory _buyingOffer) internal {
        BuySaveState(_buyingOffer);
    }

    /* -------------------------------------------------------------------------------------------------
    updateSellingOffer: this function updates a selling offer ( or deletes it if empty )
    ------------------------------------------------------------------------------------------------- */
    function updateSellingOffer(SellingOfferStructure memory _sellingOffer) internal {
         SellSaveState(_sellingOffer);
    }

    /* -------------------------------------------------------------------------------------------------
    updateBuyingOffer: this function updates a buying offer ( or deletes it if empty )
    ------------------------------------------------------------------------------------------------- */
    function updateBuyingOffer(BuyingOfferStructure memory _buyingOffer) internal {
        BuySaveState(_buyingOffer);
    }

    /* -------------------------------------------------------------------------------------------------
    getSellingOffers: this function returns selling offers of a fractionalise with given fractionalise address
    ------------------------------------------------------------------------------------------------- */
    function GetSellingOffers(string memory _tokenSymbol) internal view  returns (SellingOfferStructure[] memory) {
        SellingOfferStructure[] memory offers = new SellingOfferStructure[](SellingIndexes.length);
        uint len = SellingIndexes.length;
        uint k = 0;
        for (uint i = 0 ; i < len; i ++) {
            if (keccak256(abi.encodePacked(SellingOfferData[ SellingIndexes[i] ].TokenSymbol)) == keccak256(abi.encodePacked(_tokenSymbol))) {
                offers[k ++] = SellingOfferData[ SellingIndexes[i] ];
            }
        }
        return offers;
    }
    
    /* -------------------------------------------------------------------------------------------------
    getBuyingOffers: this function returns buying offers of a fractionalise with given fractionalise address
    ------------------------------------------------------------------------------------------------- */
    function GetBuyingOffers(string memory _tokenSymbol) internal view  returns (BuyingOfferStructure[] memory) {
        BuyingOfferStructure[] memory offers = new BuyingOfferStructure[](BuyingIndexes.length);
        uint len = BuyingIndexes.length;
        uint k = 0;
        for (uint i = 0 ; i < len; i ++) {
            if (keccak256(abi.encodePacked(BuyingOfferData[ BuyingIndexes[i] ].TokenSymbol)) == keccak256(abi.encodePacked(_tokenSymbol))) {
                offers[k++] = BuyingOfferData[ BuyingIndexes[i] ];
            }
        }
        return offers;
    }
    
    /* -------------------------------------------------------------------------------------------------
    getUserOffers: this function retrieves all the Offers of a user on NFT Pods
    ------------------------------------------------------------------------------------------------- */

    function GetUsersOffers(address _address) internal view  returns (OutputStructure memory) {
        OutputStructure memory output;

        output.UpdateBuyingOffers = new BuyingOfferStructure[](BuyingIndexes.length);
        output.UpdateSellingOffers = new SellingOfferStructure[](SellingIndexes.length);
        uint sLen = SellingIndexes.length;
        uint bLen = BuyingIndexes.length;
        uint k = 0;
        for (uint i = 0 ; i < sLen; i ++ ) {
            if (SellingOfferData[ SellingIndexes[i] ].SAddress == _address) {
                output.UpdateSellingOffers[k++] = SellingOfferData[ SellingIndexes[i] ];
            }
        }
        k =0;
        for (uint i = 0 ; i < bLen; i ++ ) {
            if (BuyingOfferData[ BuyingIndexes[i] ].BAddress == _address) {
                output.UpdateBuyingOffers[k++] = BuyingOfferData[ BuyingIndexes[i] ];
            }
        }
        return output;
    }

    // interestFromAmount returns the annual interest for a fraction given the current portion
    function interestFromAmount(FractionaliseStructure memory _fractionalise, uint _amount) private pure returns (uint) {
        return _amount / _fractionalise.InterestRate;
    }

    // amountFromInterest returns the holders amount of a fraction given his annual interest
    function amountFromInterest(FractionaliseStructure memory _fractionalise, uint interest) private pure returns (uint) {
        return interest / _fractionalise.InterestRate;
    }

    // // setStreaming updates the fractionalise interest streaming for the given address
    // function setStreaming(address _address, string memory _tokenSymbol, string memory _streamingToken, uint _amount) 
    //     internal returns (coinbalance.TransferRequest[], coinbalance.Streaming[]) {
    //     coinbalance.TransferRequest[] transfers;
    //     coinbalance.Streaming[] streamings;
        
    //     Fractionlise fractionalise = FractionaliseData[_tokenSymbol];
    //     FractionaliseStreamingStructure[] streams = GetFractionalisedStreamings(_tokenSymbol, _address);
        
    //     FractionaliseStreamingStructure stream;
    //     coinbalance.Streaming streaming;
        
    //     // create new streaming
    //     if (streams.length == 0) {
    //         streaming = coinbalance.Streaming (
    //             _address,
    //             string(abi.encodePacked("Fractionalise-Streaming-", _tokenSymbol)),
    //             Fractionalise.OwnerAddress,
    //             _streamingToken,
    //             1,
    //             block.timestamp + (10 * YearSeconds)
    //         );

    //         stream = FractionaliseStreaming(
    //             _tokenSymbol,
    //             _address
    //         );
    //     }

    //     // get existing streaming and cancel it
    //     if (streams.length == 1) {
    //         stream = streams[0];

    //         // get existing streaming
    //         streaming = coinbalance.GetStreaming(stream.StreamingId);

    //         // stop existing streaming
    //         transfers = coinbalance.StopStreamings(stream.StreamingId);
    //     }

    //     streaming.AmountPerPeriod = interestFromAmount(fractionalise, _amount) / YearSeconds;

    //     streaming.StartDate = block.timestamp;

    //     string memory id = coinbalance.CreateStreaming(streaming);
    //     streaming.StreamingId = id;
    //     stream.StreamingId = id;
    //     streams.push(streaming);

    //     FSSaveState(stream);

    //     return (transfers,  streamings);
    // }

    function TransactionAppend(TransferStructure[] memory target, TransferStructure[] memory source) internal pure returns(TransferStructure[] memory) {
        uint targetLen = target.length;
        uint sourceLen = source.length;
        TransferStructure[] memory transactions = new TransferStructure[](targetLen+sourceLen);
        uint k = 0;

        for (uint i= 0; i < targetLen; i ++) {
            transactions[k++] = target[i];
        }
        for (uint i= 0; i < sourceLen; i ++) {
            transactions[k++] = source[i];
        }

        return transactions;
    }
  
}