pragma solidity ^0.4.4;


contract Bet {

  address owner;
  address upBettor;
  address downBettor;
  uint upBet;
  uint downBet;

  function Bet() public {
    owner = msg.sender;
  }

  function kill() public {
    if (msg.sender == owner) selfdestruct(owner); 
  }

  function BetOnUp() public payable {
    // require(upBettor == address(0));
    upBettor = msg.sender;
    upBet = msg.value;
  }

  function BetOnDown() public payable {
    // require(downBettor == address(0));
    downBettor = msg.sender;
    downBet = msg.value;
  }

  function WithdrawUp() public {
    // require(msg.sender == upBettor);
    // require(upBettor != address(0));
    // TODO check timing
    // if (upWon() || (downBettor == address(0)) ){
    msg.sender.transfer(upBet + downBet);
    // }
  }

  function WithdrawDown() public {
    // require(msg.sender == downBettor);
    // require(downBettor != address(0));
    // TODO check timing
    if (!upWon() || (upBettor == address(0)) ){
      msg.sender.transfer(upBet + downBet);
    }
  }

  function upWon() private pure returns (bool out) {
    out = true;
  }
}
