//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Structures {
    // Structure to buy POD tokens from a buying market order //
    struct BuyingOfferStructure {
        string OrderId;
        string TokenSymbol;
        address PodAddress;
        address BAddress;
        string Token;
        uint Price;
    }

    struct FractionaliseStructure {
        string TokenSymbol;
        address OwnerAddress;
        uint BuyBackPrice;
        uint InitialPrice;
        uint InterestRate;
        string FuningToken;
    }
    
    struct FractionaliseStreamingStructure {
        string TokenSymbol;
        address Address;
        string StreamingId;
    }

    // Structure to buy POD tokens from a buying market order //
    struct SellingOfferStructure {
        string OrderId;
        string TokenSymbol;
        address PodAddress;
        address SAddress;
        string Token;
        uint Price;
    }

    //Structure for coinbalance.Transfer response
    struct TransferStructure {
        string Type;
        string Token;
        address From;
        address To;
        uint Amount;
        bool AvoidCheckTo;
        bool AvoidCheckFrom;
    }

    struct BuyFractionRequestStructure {
        string TokenSymbol;
        address SAddress;
        string OrderId;
        uint Amount;
        address BuyerAddress;
    }

    struct SellFractionRequestStructure {
        string TokenSymbol;
        address BAddress;
        string OrderId;
        uint Amount;
        address SellerAddress;
    }
    
    struct BuyBackRequestStructure {
        string TokenSymbol;
        address Address;
    }

    struct DeleteOrderRequest {
        address RequestAddress;
        string TokenSymbol;
        string OrderId;
    }
}