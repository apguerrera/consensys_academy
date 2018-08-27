pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/House.sol";

contract TestAdoption {
  HouseFactory houseFactory = HouseFactory(DeployedAddresses.HouseFactory());

  // Testing the adopt() function
  function testHousemate() public {
    address returnedId = houseFactory;

    address expected = 0x123;

    Assert.equal(returnedId, expected, "Adoption of housemate ID 8 should be recorded.");
  }



}
