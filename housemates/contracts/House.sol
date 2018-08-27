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
// House Points Interface
// ----------------------------------------------------------------------------

contract HousePointsInterface {
    // function name() public view returns (string);
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint numPoints) public returns (bool success) ;
    function mint (address to, uint numPoints) public returns (bool success) ;
    function burn (address from, uint numPoints) public returns (bool success);
    event TransferPoints(address indexed fromAddress,address indexed toAddress, uint numPoints);
    event MintPoints(address indexed toAddress, uint numPoints);
    event BurnPoints(address indexed fromAddress, uint numPoints);

}

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
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
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
        bool initialised;
        mapping(address => Housemate) housemates;
    }
    event HousemateAdded(address indexed housemateAddress, string name);
    event HousemateRemoved(address indexed housemateAddress, string name);
    event HousemateNameChanged(address indexed housemateAddress, string name);

    function init(Data storage self) internal {
        require(!self.initialised);
        self.initialised = true;
    }
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
// House Points
// ----------------------------------------------------------------------------

contract HousePoints is HousePointsInterface, Owned {
    using SafeMath for uint;
    mapping (address => uint) points;
    uint _totalSupply;

    event TransferPoints(address indexed fromAddress,address indexed toAddress, uint numPoints);
    event MintPoints(address indexed toAddress, uint numPoints);
    event BurnPoints(address indexed fromAddress, uint numPoints);

    constructor () public {
        _totalSupply = 0;
    }

    function totalSupply() public view returns (uint) {
       return _totalSupply - points[address(0)];
    }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return points[tokenOwner];
    }
    function transfer(address to, uint numPoints) public returns (bool success) {
        // check enough Points
        require(points[msg.sender] >= numPoints);
        points[msg.sender] = points[msg.sender].sub(numPoints);
        points[to] = points[to].add(numPoints);
        emit TransferPoints(msg.sender, to, numPoints);

        return true;
    }
    function mint (address to, uint numPoints) public returns (bool success) {
        _totalSupply = _totalSupply.add(numPoints);
        points[to] = points[to].add(numPoints);
        return true;

    }
    function burn (address from, uint numPoints) public returns (bool success){
        require(points[from] >= numPoints);
        _totalSupply = _totalSupply.sub(numPoints);
        points[from] = points[from].sub(numPoints);
        return true;
    }
    function () public payable {
        revert();
    }
}

// ----------------------------------------------------------------------------
// House Contract
// ----------------------------------------------------------------------------

contract House {
    using SafeMath for uint;
    using Housemates for Housemates.Data;
    Housemates.Data housemateData;
    HousePointsInterface public housePoints;

    uint public numberOfRooms;
    string public houseName;
    bool public active;
    uint public numNewTokens;

    modifier onlyHousemate {
      require(housemateData.isHousemate(msg.sender));
      _;
    }

    constructor (string _houseName, address _housePointsAddress, uint _houseRooms) public {
      numberOfRooms = _houseRooms;
      houseName = _houseName;
      active = true;
      // housemateData.addHousemate(msg.sender, housemateName);
      housePoints = HousePointsInterface(_housePointsAddress);
    }

    function activateHouse() public onlyHousemate {
      active = true;
    }
    function killHouse() public onlyHousemate {
      active = false;
    }

    function addHousemate(address newAddress, string name) public onlyHousemate {
        require(active);
        housemateData.addHousemate(newAddress, name);
        housePoints.mint(newAddress, numNewTokens);
    }

    function removeHousemate(address deadAddress) public onlyHousemate {
        require(active);
        housePoints.burn(deadAddress, uint(-1));
        housemateData.removeHousemate(deadAddress);
    }

    function isHousemates() public view onlyHousemate returns (string does_exist) {
      does_exist = housemateData.housemates[msg.sender].name;
    }

}

// ----------------------------------------------------------------------------
// House Factory
// ----------------------------------------------------------------------------
contract HouseFactory is Owned {
    House[] public activeHouses;
    HousePointsInterface[] public activePoints;
    event NewHouse(address indexed createdAddress, string name, uint rooms);

    function createNewHouse (string houseName, uint houseRooms, string housemateName, uint newHousePoints) public returns (House house,  HousePoints points ) {
        points = new HousePoints();
        activePoints.push(points);
        house = new House(houseName, address(points), houseRooms);
        house.addHousemate(msg.sender, housemateName);
        points.mint(msg.sender, newHousePoints);
        activeHouses.push(house);
        emit NewHouse(msg.sender, houseName, houseRooms);
    }

    function numberOfActiveHouses() public view returns (uint) {
        return activeHouses.length;
    }
    function numberOfActivePoints() public view returns (uint) {
        return activePoints.length;
    }

    function () public payable {
        revert();
    }
}
