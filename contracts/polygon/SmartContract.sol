//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./Fractionalise.sol";

contract SmartContract is FractionaliseContract {
   
    function getFractionaliseInfo (string memory _tokenSymbol) external view returns (FractionaliseStructure memory) {
        return FractionaliseData[_tokenSymbol];
    }

    function getSellingOffers (string memory _tokenSymbol) external view returns (SellingOfferStructure[] memory) {
        return GetSellingOffers(_tokenSymbol);
    }
   
    function getBuyingOffers (string memory _tokenSymbol) external view returns (BuyingOfferStructure[] memory) {
        return GetBuyingOffers(_tokenSymbol);
    }
   
    function getUserOffers (address _address) external view returns (OutputStructure memory) {
       return GetUsersOffers(_address);
    }

    function fractionalise (FractionaliseStructure memory _fractionalise) external  
        onlyOwnerOf(_fractionalise.OwnerAddress) returns (OutputStructure memory) {
        return FractionaliseToken (_fractionalise);
    }

    function newBuyOrder (BuyingOfferStructure memory _buyingOffer) external 
        onlyOwnerOf(_buyingOffer.BAddress) returns(OutputStructure memory) {
        return NewBuyOrder(_buyingOffer);
    }

    function deleteBuyOrder(DeleteOrderRequest memory _buyingOffer) external onlyOwnerOf(_buyingOffer.RequestAddress) 
     returns(OutputStructure memory) {
        return DeleteBuyOrder(_buyingOffer);
    }

    function newSellOrder (SellingOfferStructure memory _sellingOffer) external onlyOwnerOf(_sellingOffer.SAddress)
        returns (OutputStructure memory) {
        return NewSellOrder(_sellingOffer);
    }

    function deleteSellOrder (DeleteOrderRequest memory _sellingOffer) external onlyOwnerOf(_sellingOffer.RequestAddress) 
     returns(OutputStructure memory) {
        return DeleteSellOrder(_sellingOffer);
    }
   
    function buyFraction (BuyFractionRequestStructure memory _buyFractionRequest) external onlyOwnerOf(_buyFractionRequest.BuyerAddress) 
     returns(OutputStructure memory) {
        return BuyFraction(_buyFractionRequest);
    }
    
    function sellFraction (SellFractionRequestStructure memory _sellFractionRequest) external onlyOwnerOf(_sellFractionRequest.SellerAddress) 
     returns(OutputStructure memory) {
        return SellFraction(_sellFractionRequest);
    }
    
    function buyFractionalisedBack (BuyBackRequestStructure memory _buyBackRequest) external onlyOwnerOf(_buyBackRequest.Address) 
     returns(OutputStructure memory) {
        return BuyFractionalisedBack(_buyBackRequest);
    }
}