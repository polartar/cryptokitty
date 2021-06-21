const SmartContract = artifacts.require("./Fractionalise.sol");

contract("SmartContract", accounts => {
  it("...should create a new buyorder.", async () => {
    const smartContractInstance = await SmartContract.deployed();

    //create new buyorder
    await smartContractInstance.newBuyOrder(("testid", "testSymbol", accounts[0], accounts[1], 2, "token", 4));
    const results  = await smartContractInstance.getBuyingOffers("testSymbol");
    assert.equal(results[0].symbolToken, "testSymbol", "New buyorder was created");
  });

  it("...should delete a new buyorder.", async () => {
    const smartContractInstance = await SmartContract.deployed();

    //create new buyorder
    await smartContractInstance.newBuyOrder(("testid", "testSymbol", accounts[0], accounts[1], 2, "token", 4));
    
    //delete the buyorder
    await smartContractInstance.deleteBuyOrder(("testid", "testSymbol", accounts[0], accounts[1], 2, "token", 4));
    const results  = await smartContractInstance.getBuyingOffers("testSymbol");
    assert.equal(results.length, 0, "The buyorder was removed");
  });

  it("...should sell fraction", async () => {
    const smartContractInstance = await SmartContract.deployed();

    //create new buyoffer
    await smartContractInstance.newBuyOrder(("testid", "testSymbol", accounts[0], accounts[1], 2, "token", 4));

    //sell fraction
    const result = await smartContractInstance.sellFraction(("testSymbol",accounts[0], "testid", 5, accounts[1]));
    assert.equal(results, "offer has not enough funds to satisfy request", "Not enough money");

    //sell fraction
    const result = await smartContractInstance.sellFraction(("testSymbol",accounts[0], "testid", 3, accounts[1]));
    const results  = await smartContractInstance.getBuyingOffers("testSymbol");
    assert.equal(results[0].Amount, 2, "Fraction is selled");
  });
});
