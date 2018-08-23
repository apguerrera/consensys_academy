pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/House.sol";

contract TestAdoption {
  House house = House(DeployedAddresses.House());

  // Testing the adopt() function
  function testHousemate() public {
    uint returnedId = house.housemate(8);

    uint expected = 8;

    Assert.equal(returnedId, expected, "Adoption of housemate ID 8 should be recorded.");
  }



}
