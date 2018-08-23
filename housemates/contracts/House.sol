pragma solidity ^0.4.23;

library Housemates {
    struct Housemate {
      string name;
      uint room;
      bool exists;
    }
    struct Data {
        mapping(address => Housemate) housemates;
    }
    event HousemateAdded(address indexed housemateAddress, string name);
    event HousemateRemoved(address indexed housemateAddress, string name);
    event HousemateNameChanged(address indexed housemateAddress, string name);

    function isHousemate(Data storage self, address housemateAddress) internal view returns (bool) {
        // check if housemate exists
        require(self.housemates[housemateAddress].exists == true);
    }
    function addHousemate(address account, string name) internal {
        // add housemate
        emit HousemateAdded(account, name);
    }
    function removeHousemate(address account, string name) internal {
        // remove housemate
        emit HousemateAdded(account, name);
    }
    function changeName(address account, string name) internal {
        // set housemate name
        emit HousemateNameChanged(account, name);
    }
}

contract House {
  using Housemates for Housemates.Data;
  Housemates.Data housemates;
  uint public no_rooms;
  string public house_name;

  modifier onlyHousemate {
      require(housemates.isHousemate(msg.sender));
      _;
  }

  constructor () public {
      no_rooms = 5;
      house_name = "Stanley St";
  }


}
