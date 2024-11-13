// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract DonationToken {
    uint8 private constant _minTransferPerc = 90;
    string private constant _name = "Donation Tokens";
    string private constant _sym = "DNT";

    uint128 private immutable _totalTokens = 1000000000000;
    
    uint128 public activeTokens;
    address public immutable owner;

    mapping (address => bool) _admins;

    mapping (address => uint128) _donations;

    constructor() {
        owner = msg.sender;
        _admins[owner] = true;
        activeTokens = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    modifier onlyAdmins() {
        require(_admins[msg.sender], "You are not an admin!");
        _;
    }

    modifier onlyAdminsAndSender(address _sender) {
        require(_admins[msg.sender] || _sender == msg.sender, "You don't have access to this!");
        _;
    }

    function name() external pure returns (string memory){
        return _name;
    }

    function symbol() external pure returns (string memory){
        return _sym;
    }

    function decimals() external pure returns (uint8){
        return 8;
    }

    function totalSupply() external pure returns (uint128){
        return _totalTokens;
    }

    function owndership() public view returns (bool) {
        return msg.sender == owner;
    }

    function addAdmin(address _newAdmin) public onlyOwner returns (bool) {
        require(_newAdmin != address(0));

        _admins[_newAdmin] = true;
        return true;
    }

    function removeAdmin(address _adminOut) public onlyOwner returns (bool) {
        require(_adminOut != address(0) && _admins[_adminOut], "Endereco para remover invalido");

        _admins[_adminOut] = false;

        return true;
    }

    function donationOf(address _from) external view onlyAdminsAndSender(_from) returns (uint128 balance) {
        require(_from != address(0));

        return _donations[_from];
    }

    function donate(uint128 _value) external {
        require(!_admins[msg.sender], "Only non-admins should donate!");

        // bool success = _transferFrom(msg.sender, owner, _value);
        _donations[msg.sender] += _value;
        activeTokens += _value;
    }

    function extractDonation(uint128 _value) external onlyAdmins {
        require(_value <= activeTokens);

        activeTokens -= _value;
    }

    // function transfer(address _to, uint128 _value) external returns (bool success) {
    //     require((_balances[msg.sender] * _minTransferPerc) / 100 < _value);
    //     require(_to != address(0));

    //     _balances[msg.sender] -= _value;
    //     _balances[_to] += _value;

    //     return true;
    // }

    function _transferFrom(address _from, address _to, uint128 _value) private returns (bool success) {
        require((_donations[_from] * _minTransferPerc) / 100 < _value);
        require(_from != address(0));
        require(_to != address(0));
        require(_from == msg.sender || _from == owner);

        _donations[_from] -= _value;
        _donations[_to] += _value;

        return true;
    }
}