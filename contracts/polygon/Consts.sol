//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

abstract contract Consts {
    string constant BuyingOffersIndex = "FRACTIONALISE_BUYING";
    string constant SellingOffersIndex = "FRACTIONALISE_SELLING";
    string constant FractionaliseIndex = "FRACTIONALISE";
    string constant FractionaliseStreamingIndex = "FRACTIONALISE_STREAMING";
    uint constant YearSeconds = 365 * 24 * 60 * 60;
}
