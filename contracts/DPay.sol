// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DPay {
  address public owner;

  event ownerChanged(address prevOwner, address indexed newOwner);
  event nameAddedToWallet(address indexed addr, string indexed name);
  event requestCreated(address indexed addr, uint256 amount, string message, address user);
  event requestPaid(address indexed sender, address receiver, uint256 amount);

  constructor () {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function changeOwner(address _owner) public onlyOwner {
    owner = _owner;
    emit ownerChanged(msg.sender, owner);
  }

  struct Requester {
    address requester;
    uint256 amount;
    string message;
    string name;
  }

  struct SendReceive {
    string action;
    uint256 amount;
    string message;
    address secondPartyAddress;
    string secondPartyName;
  }

  struct UserName {
    string name;
    bool hasName;
  }

  mapping(address => UserName) public walletNames;
  mapping(address => Requester[]) public requests;
  mapping(address => SendReceive[]) public history;

  // add Name to Wallet address
  function addName(string memory _name) public {
    walletNames[msg.sender] = UserName(_name, true);
    emit nameAddedToWallet(msg.sender, _name);
  }

  // Create a payment request
  function createRequest(address _user, uint256 _amount, string memory _msg) public {
    Requester memory newRequest;
    newRequest.requester = msg.sender;
    newRequest.amount = _amount;
    newRequest.message = _msg;
    if (walletNames[msg.sender].hasName) {
      newRequest.name = walletNames[msg.sender].name;
    }

    requests[_user].push(newRequest);
    emit requestCreated(msg.sender, _amount, _msg, _user);
  }

  // Paying the request
  function payRequest(uint256 _request) public payable {
    require(_request < requests[msg.sender].length, "No such requests !");
    Requester[] storage myRequests = requests[msg.sender];
    Requester storage payableRequest = myRequests[_request];

    uint256 toPay = payableRequest.amount * 1e18;

    require(msg.value == toPay, "Pay correct amount !");
    (bool success, ) = payable(payableRequest.requester).call{value:msg.value}("");
    require(success, "Transfer failed !");

    _addHistory(msg.sender, payableRequest.requester, payableRequest.amount, payableRequest.message);
    myRequests[_request] = myRequests[myRequests.length - 1];
    myRequests.pop();
    emit requestPaid(msg.sender, payableRequest.requester, payableRequest.amount);
  }

  // Updating history of both sender and receiver
  function _addHistory(address _sender, address _receiver, uint256 _amount, string memory _msg) private {
    SendReceive memory newSend;
    newSend.action = "SEND";
    newSend.amount = _amount;
    newSend.message = _msg;
    newSend.secondPartyAddress = _receiver;
    if (walletNames[_receiver].hasName) {
      newSend.secondPartyName = walletNames[_receiver].name;
    }

    history[_sender].push(newSend);

    SendReceive memory newReceive;
    newReceive.action = "RECEIVE";
    newReceive.amount = _amount;
    newReceive.message = _msg;
    newReceive.secondPartyAddress = _sender;
    if (walletNames[_sender].hasName) {
      newReceive.secondPartyName = walletNames[_sender].name;
    }

    history[_receiver].push(newReceive);
  }

  // Getting all requests
  function getMyRequests(address _user) public view returns(address[] memory, uint256[] memory, string[] memory, string[] memory) {
    address[] memory addrs = new address[](requests[_user].length);
    uint256[] memory amnt = new uint256[](requests[_user].length);
    string[] memory msge = new string[](requests[_user].length);
    string[] memory nme = new string[](requests[_user].length);

    for (uint i=0; i<requests[_user].length; i++) {
      Requester storage myRequests = requests[_user][i];
      addrs[i] = myRequests.requester;
      amnt[i] = myRequests.amount;
      msge[i] = myRequests.message;
      nme[i] = myRequests.name;
    }

    return (addrs, amnt, msge, nme);
  }

  // Get history of user
  function getHistory(address _user) public view returns(SendReceive[] memory) {
    return history[_user];
  }

  // Get username of the wallet
  function getMyName(address _user) public view returns(UserName memory) {
    return walletNames[_user];
  }

}
