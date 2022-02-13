pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  uint256 public deadline;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  bool public openForWithdraw = false;

  event Stake (address indexed sender, uint256 indexed amount);


  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = block.timestamp + 7 days;
  }

  

  modifier notCompleted() {
      require(!exampleExternalContract.completed(), "Completed already");
      _;
  }

  function _deadlineReached() private view returns (bool) {
      return block.timestamp >= deadline;
  }

  function _hasReachedThreshold() private view returns (bool) {
      return address(this).balance >= threshold;
  }




  function stake() public payable notCompleted {
    require(
      !_deadlineReached(),
      "deadline reached, staking full"
    );
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  function execute() public notCompleted {
    require(_deadlineReached(), "staking still avalable");
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  } 

  function withdraw(address payable staker) public notCompleted {
    require(openForWithdraw, "can't withdraw yet");
    require(balances[staker] > 0, "You haven't deposited");
    uint256 amount = balances[staker];
    balances[staker] = 0;
    (bool success, bytes memory data) = staker.call{value: amount}("");
    require(success, "Failed to send Ether!");
  }

  function timeLeft() public view returns (uint256) {
    return _deadlineReached() ? 0 : deadline  - block.timestamp;
  }
  
  
  receive() external payable {
    stake();
  }  

  


  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:

  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  // After some `deadline` allow anyone to call an `execute()` function

  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend



  
}
