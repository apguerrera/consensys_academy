pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
// Housemates Project
//
// GitHub: https://github.com/apguerrera/consensys_academy/housemates
//
// (c) Adrian Guerrera
// The MIT Licence.
// ----------------------------------------------------------------------------
// Library and factory constructor inspired by
// (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
// the ClubEth.App Project - 2018. The MIT Licence.
// GitHub: https://github.com/bokkypoobah/ClubEth

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    function transferOwnershipImmediately(address _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


// ----------------------------------------------------------------------------
// Housemate Library
// ----------------------------------------------------------------------------

library Housemates {
    struct Housemate {
      string name;
      bool exists;
    }
    struct Data {
        mapping(address => Housemate) housemates;
    }
    event HousemateAdded(address indexed housemateAddress, string name);
    event HousemateRemoved(address indexed housemateAddress, string name);
    event HousemateNameChanged(address indexed housemateAddress, string name);

    function isHousemate(Data storage self, address account) internal view returns (bool) {
        // check if housemate exists
        return self.housemates[account].exists;
    }

    function addHousemate(Data storage self, address account, string name) internal {
        // add housemate
        self.housemates[account] = Housemate(name, true);
        emit HousemateAdded(account, name);
    }
    function removeHousemate(Data storage self,address account) internal {
        // remove housemate
        string memory _name =  self.housemates[account].name;
        delete self.housemates[account];
        emit HousemateRemoved(account, _name);
    }
    function changeName(address account, string name) internal {
        // set housemate name
        emit HousemateNameChanged(account, name);
    }

}

// ----------------------------------------------------------------------------
// House Contract
// ----------------------------------------------------------------------------

contract House{
    using Housemates for Housemates.Data;
    Housemates.Data housemates;
    uint8 public no_rooms;
    string public house_name;
    bool public testing;

    modifier onlyHousemate {
      require(housemates.isHousemate(msg.sender));
      _;
    }

    constructor (string houseName, uint8 houseRooms) public {
      no_rooms = houseRooms;
      house_name = houseName;
      housemates.addHousemate(msg.sender, "Owner");
      testing = false;
    }

    function test() public onlyHousemate {
      testing = true;
    }

    function addHousemate(address newAddress, string name) public onlyHousemate {
      housemates.addHousemate(newAddress, name);
    }

    function removeHousemate(address deadAddress) public onlyHousemate {
      housemates.removeHousemate(deadAddress);
    }

    function getHousemates() public view onlyHousemate returns (string does_exist) {
      does_exist = housemates.housemates[msg.sender].name;
    }

}


// ----------------------------------------------------------------------------
// House Factory
// ----------------------------------------------------------------------------
contract HouseFactory is Owned {
    House[] public activeHouses;

    event NewHouse(address indexed createdAddress, string name, uint8 rooms);

    constructor () public {
      createNewHouse("Stanley St", 5);
    }

    function createNewHouse (string houseName, uint8 houseRooms) public returns (House house) {
        house = new House(houseName, houseRooms);
        emit NewHouse(msg.sender, houseName,houseRooms);
    }

    function numberOfActiveHouses() public view returns (uint) {
        return activeHouses.length;
    }
    function () public payable {
        revert();
    }

}
