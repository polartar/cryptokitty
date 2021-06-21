//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./Helper.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SmartContract is Helper, ERC20 {
    constructor () ERC20("SimpleToken", "SIM") {
        _mint(_msgSender(), 10000 * (10 ** uint256(decimals())));
    }
    function _transfer(address _from, address _to, string memory _tokenSymbol, uint _price) private {
        FractionaliseData[_tokenSymbol].OwnerAddress = _to;

        emit Transfer(_from, _to, _price);
    }
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
    
    function FractionaliseToken(FractionaliseStructure memory _input) private returns (OutputStructure memory) {
        OutputStructure memory output;
        address addr = address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number))))));

        SellingOfferStructure memory offer = SellingOfferStructure({
            OrderId: GetTxID(),
            TokenSymbol: _input.TokenSymbol,
            PodAddress: addr,
            SAddress: _input.OwnerAddress,
            Token: _input.FuningToken,
            Price: _input.InitialPrice
        });
        
        offer.PodAddress = addr;

        _transfer( _input.OwnerAddress, offer.PodAddress, _input.TokenSymbol, _input.BuyBackPrice);
        TransferStructure memory transfer = TransferStructure ({
            Type:           "fractionalise_media",
            Token:          _input.TokenSymbol,
            From:           _input.OwnerAddress,
            To:             offer.PodAddress,
            AvoidCheckTo:   true,
            AvoidCheckFrom: true,
            Amount: _input.InitialPrice
        });

        output.UpdateFractionalise[0] =  _input;
        output.UpdateSellingOffers[0] = offer;
        output.Transactions[0] = transfer;
        
        return output;
    }

    function NewBuyOrder(BuyingOfferStructure memory _buyingOffer) private returns(OutputStructure memory) {
        OutputStructure memory output;
        _buyingOffer.OrderId = GetTxID();
        TransferStructure memory transfer = TransferStructure ({
            Type: "Fractionalise_Buy_Offer",
            Token: _buyingOffer.Token,
            From: _buyingOffer.BAddress,
            To: _buyingOffer.PodAddress,
            Amount: _buyingOffer.Price,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        registerBuyingOffer(_buyingOffer);
         _transfer( _buyingOffer.BAddress, _buyingOffer.PodAddress, _buyingOffer.TokenSymbol, _buyingOffer.Price);

        output.Transactions[0] = transfer;
        output.UpdateBuyingOffers[0] = _buyingOffer;

        return output;
    }

    function NewSellOrder(SellingOfferStructure memory _sellingOffer) private returns (OutputStructure memory) {
        OutputStructure memory output;
        FractionaliseStructure memory _fractionalise = FractionaliseData[_sellingOffer.TokenSymbol];

        TransferStructure memory transfer = TransferStructure({
            Type: "Fractionalise_Sell_Offer",
            Amount: _sellingOffer.Price,
            Token: _fractionalise.TokenSymbol,
            From: _fractionalise.OwnerAddress,
            To: _sellingOffer.PodAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        _sellingOffer.OrderId = GetTxID();
        registerSellingOffer(_sellingOffer);

        _transfer( _fractionalise.OwnerAddress, _sellingOffer.PodAddress, _sellingOffer.TokenSymbol, _sellingOffer.Price);
        
        output.Transactions[0] = transfer;
        output.UpdateSellingOffers[0] = _sellingOffer;

        return output;
    }

    function DeleteBuyOrder(DeleteOrderRequest memory _request) private returns (OutputStructure memory) {
        BuyingOfferStructure memory offer;
        offer.TokenSymbol = _request.TokenSymbol;
        offer.BAddress = _request.RequestAddress;
        offer.OrderId = _request.OrderId;

        (bool exists, BuyingOfferStructure memory offer1) = BuyLoadState(offer);
        
        require(exists, "such offer does not exists");
        offer = offer1;
     	// money recover transactions
        TransferStructure[] memory transactions;
        
        // recover funding tokens
        transactions[0] = TransferStructure ({
            Type: "NFT_Pod_Buy_Order_Delete",
            Amount: offer.Price,
            Token: offer.Token,
            From: offer.PodAddress,
            To: offer.BAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });
        _transfer( offer.PodAddress, offer.BAddress, offer.Token, offer.Price);

        // recover media tokens in case of any
        transactions[1] = TransferStructure ({
            Type: "NFT_Pod_Buy_Order_Delete",
            Amount: offer.Price,
            Token: offer.TokenSymbol,
            From: offer.PodAddress,
            To: offer.BAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        _transfer( offer.PodAddress, offer.BAddress, offer.TokenSymbol, offer.Price);
      
        // delete offer state
        BuyDeleteState(offer);

        OutputStructure memory output;
        output.Transactions = transactions;

        return output;
    }

    function DeleteSellOrder(DeleteOrderRequest memory _request) private returns(OutputStructure memory) {
        SellingOfferStructure memory offer;
        offer.TokenSymbol = _request.TokenSymbol;
        offer.SAddress = _request.RequestAddress;
        offer.OrderId = _request.OrderId;

        (bool exists, SellingOfferStructure memory offer1) = SellLoadState(offer);

        require(exists, "such offer does not exists");
        offer = offer1;
     	// money recover transactions
        TransferStructure[] memory transactions;
        
        // recover funding tokens

        transactions[0] = TransferStructure ({
            Type: "NFT_Pod_Sell_Offer_Delete",
            Amount: offer.Price,
            Token: offer.Token,
            From: offer.PodAddress,
            To: offer.SAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        // recover media tokens in case of any

        transactions[1] = TransferStructure ({
            Type: "NFT_Pod_Sell_Offer_Delete",
            Amount: offer.Price,
            Token: offer.TokenSymbol,
            From: offer.PodAddress,
            To: offer.SAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        // delete offer state
        SellDeleteState(offer);

        OutputStructure memory output;
        output.Transactions = transactions;

        return output;
    }

    function BuyFraction(BuyFractionRequestStructure memory _buyFractionRequest) private returns(OutputStructure memory) {
        SellingOfferStructure memory offer;
        
        offer.OrderId = _buyFractionRequest.OrderId;
        offer.TokenSymbol = _buyFractionRequest.TokenSymbol;
        offer.SAddress = _buyFractionRequest.SAddress;

        (bool exists, SellingOfferStructure memory offer1) = SellLoadState(offer);
        require(exists, "such offer does not exists");
        offer = offer1;
        // calculate buy price
        uint amountprice = offer.Price;

        // load fractionalise
        FractionaliseStructure memory _fractionalise = FractionaliseData[offer.TokenSymbol];

        //update streamings
        TransferStructure[] memory transactions;

        if (_buyFractionRequest.BuyerAddress != _fractionalise.OwnerAddress) {
             _transfer( _buyFractionRequest.BuyerAddress, offer.SAddress, offer.TokenSymbol, offer.Price);
        }
       
        if (offer.SAddress != _fractionalise.OwnerAddress) {
             _transfer( offer.PodAddress, _buyFractionRequest.BuyerAddress, offer.TokenSymbol, offer.Price);
        }

        // make transfers   
        TransferStructure memory buyTransfer = TransferStructure ({
            Type: "Fractionalise_Buying",
            Token: offer.Token,
            Amount: amountprice,
            From: _buyFractionRequest.BuyerAddress,
            To: _buyFractionRequest.SAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });
       
        TransferStructure memory sellTransfer = TransferStructure ({
            Type: "Fractionalise_Buying",
            Token: _fractionalise.TokenSymbol,
            Amount: _buyFractionRequest.Amount,
            From: offer.PodAddress,
            To: _buyFractionRequest.BuyerAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        transactions[0] = buyTransfer;
        transactions[1] = sellTransfer;
      
        // update offer if not empty, delete if empty
         updateSellingOffer(offer);

        // output of the result

        OutputStructure memory output;
        output.Transactions = transactions;
        // output.UpdateStreamings = streamings;
        output.UpdateSellingOffers[0] = offer;

        return output;
    }
    
    function SellFraction(SellFractionRequestStructure memory _sellFractionRequest) private returns (OutputStructure memory) {
        BuyingOfferStructure memory offer;
        offer.OrderId = _sellFractionRequest.OrderId;
        offer.TokenSymbol = _sellFractionRequest.TokenSymbol;
        offer.BAddress = _sellFractionRequest.BAddress;
        

        (bool exists, BuyingOfferStructure memory offer1) = BuyLoadState(offer);
        require(exists, "such offer does not exists");

        offer = offer1;
        
        // load fractionalise
        FractionaliseStructure memory _fractionalise = FractionaliseData[offer.TokenSymbol];

        //update streamings
        TransferStructure[] memory transactions;
      

        if (offer.BAddress != _fractionalise.OwnerAddress) {
            _transfer( offer.PodAddress, _sellFractionRequest.SellerAddress, offer.TokenSymbol, offer.Price);
        }
       
        if (_sellFractionRequest.SellerAddress != _fractionalise.OwnerAddress) {
             _transfer( _sellFractionRequest.SellerAddress, offer.BAddress, offer.TokenSymbol, offer.Price);
        }

        // Transfer to the Buyer of the offer from the Seller //
        TransferStructure memory selling = TransferStructure ({
            Type: "Fractionalise_Selling",
            Token: _fractionalise.TokenSymbol,
            Amount: _sellFractionRequest.Amount,
            From: _sellFractionRequest.SellerAddress,
            To: offer.BAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });
       
       // Transfer to the Seller the selling amount from the Pod //
        TransferStructure memory buying = TransferStructure ({
            Type: "Fractionalise_Selling",
            Token: offer.Token,
            Amount: _sellFractionRequest.Amount * offer.Price,
            From: offer.PodAddress,
            To: _sellFractionRequest.SellerAddress,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });

        transactions[0] = selling;
        transactions[1] = buying;

        // Update balances with the transfers by invoking CoinBalance Chaincode //
        // coinbalance.Multitransfer r = coinbalance.Multitransfer(transactions);
        
        // Update offer if not empty, delete if empty //
        updateBuyingOffer(offer);

        // output of the result

        OutputStructure memory output;
        output.Transactions = transactions;
        // output.UpdateStreamings = streamings;
        output.UpdateBuyingOffers[0] = offer;

        return output;
    }

    function BuyFractionalisedBack(BuyBackRequestStructure memory _input) private returns(OutputStructure memory) {
        FractionaliseStructure memory _fractionalise = FractionaliseData[_input.TokenSymbol];
        SellingOfferStructure memory sellOffer = SellingOfferData[_fractionalise.FuningToken];
        _transfer( sellOffer.SAddress,  _input.Address, _input.TokenSymbol, sellOffer.Price);
        _transfer( _fractionalise.OwnerAddress, sellOffer.SAddress, _input.TokenSymbol, _fractionalise.BuyBackPrice);

        // generate transfers
        TransferStructure memory selling = TransferStructure ({
            Type: string(abi.encodePacked("Buy-Back-Fractionalise-", _input.TokenSymbol)),
            Token: _fractionalise.TokenSymbol,
            Amount: sellOffer.Price,
            From: sellOffer.SAddress,
            To: _input.Address,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });
    
        TransferStructure memory buying = TransferStructure ({
            Type: string(abi.encodePacked("Buy-Back-Fractionalise-", _input.TokenSymbol)),
            Token: _fractionalise.FuningToken,
            From: _fractionalise.OwnerAddress,
            To: sellOffer.SAddress,
            Amount: _fractionalise.BuyBackPrice,
            AvoidCheckTo: false,
            AvoidCheckFrom: false
        });
        TransferStructure[] memory transactions;
        transactions[0] = buying;
        transactions[1] = selling;

        OutputStructure memory output;
        output.Transactions = transactions;
        
        return output;
    }
}

  