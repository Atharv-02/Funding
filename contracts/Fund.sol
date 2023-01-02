// Get funds from users
// Withdraw Funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error NotOwner();
contract Fund {
    using PriceConverter for uint256;

    //Two keywords that make a variable unchangeable - immutable and constant 
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    address[] public funders;

    constructor(){
        i_owner=msg.sender;
    }

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] = msg.value;
        funders.push(msg.sender);
    }
    
    function withdraw() public  {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //setting funders to empty array 
        funders = new address[](0);
        //withdrawing funds

        // transefer 
        // payable(msg.sender).transfer(address(this).balance);
        // send
        // bool sendSuccess=payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send Failed");
        // call
        (bool callSuccess,)=payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess,"call Failed");
    }

    modifier onlyOwner{
        // require(msg.sender==i_owner,"Seder is not owner");
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }
    // What happens if someone sends this contract ETH without calling the fund function 
    receive() external payable {
        fund();
    }
    fallback() external {
        fund();
    }
}
