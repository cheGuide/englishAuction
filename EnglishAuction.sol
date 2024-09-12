// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract EnglishAuction{
    
    string public item;
    address payable public immutable seller;
    uint256 public endAt;
    bool public started;
    bool public ended;
    uint256 public highestBid;
    address public highestBidder;
    mapping(address => uint256) public bids;
    uint time;
    
    event Start(string item, uint256 highestBid);
    event Bid(address biddrer, uint256 bid);
    event End(address biddrer, uint256 bid);
    event Withdraw(address sender, uint256 amount);

   constructor(string memory _item, uint256 _startBid, uint _time) {
        item = _item;
        highestBid = _startBid;
        seller = payable(msg.sender);
        time = _time;
    }

    modifier onlySeller(){
        require(msg.sender == seller, "not an owner");
        _;
    }

    modifier notEnded(){
        require(block.timestamp < endAt, "already ended");
        _;
    }
    modifier hadStarted(){
        require(started, "not started" );
        _;
    }

    function start() public onlySeller{
        require(!started, "already started");
        started = true;
        endAt = block.timestamp + time;
        emit Start(item, highestBid);
    }

    function bid() public payable notEnded hadStarted{
        bids[msg.sender] += msg.value;
        if ( bids[msg.sender] > highestBid){
            highestBid = bids[msg.sender];
            highestBidder = msg.sender;
        }
        emit Bid(msg.sender, msg.value);
    }

    function withdraw() public{
        uint value = bids[msg.sender];
        require(bids[msg.sender] > 0, "no money");
        bids[msg.sender] = 0;
        address payable receiver = payable(msg.sender);
        receiver.transfer(value);

        emit Withdraw(receiver,value);
    }

    function end() public hadStarted{
        require(!ended, "already ended");
        require(block.timestamp < endAt, "not time to stop yet");
        ended = true;
        emit End(highestBidder, highestBid);
    }

    function timeToEnd() public view returns(uint){
        return endAt- block.timestamp;
    } 
}