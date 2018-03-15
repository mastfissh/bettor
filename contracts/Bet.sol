pragma solidity ^0.4.4;


contract Bet {

  address owner;
  address upBettor;
  address downBettor;
  uint ownerPayout;
  uint upBet;
  uint downBet;
  uint firstBetTime;
  uint secondBetTime;

  function Bet() public {
    owner = msg.sender;
  }

  function kill() public {
    require(msg.sender == owner);
    // Don't let owner take ether if bets are ongoing
    if (upBet == 0 && downBet == 0){
      selfdestruct(owner);
    } else {
      // Unless it's been a week
      require (now > (firstBetTime + 7 day));
      selfdestruct(owner);
    }
  }

  function BetOnUp() public payable {
    // Can only register as upbettor if no-one else beat you there
    require(upBettor == address(0));
    upBettor = msg.sender;
    upBet = msg.value;
    if (firstBetTime == 0){
      firstBetTime = now;
    } else {
      // TODO schedule an oracle call to get the result
      secondBetTime = now;
    }
  }

  function BetOnDown() public payable {
    // Can only register as downbettor if no-one else beat you there
    require(downBettor == address(0));
    downBettor = msg.sender;
    downBet = msg.value;
    if (firstBetTime == 0){
      firstBetTime = now;
    } else {
      // TODO schedule an oracle call to get the result
      secondBetTime = now;
    }
  }

  function WithdrawUp() public {
    uint payout = 0;
    require(msg.sender == upBettor);
    // If no-one matches the bet in a day, lets you withdraw
    require (now > (firstBetTime + 1 day));
    if (downBettor == address(0){
      payout = upBet;
      reset();
    } else {
      require (now > (secondBetTime + 1 day));
      require(upWon());
      payout = payout();
      reset();
    }
    msg.sender.transfer(payout);
  }

  function WithdrawDown() public {
    uint payout = 0;
    require(msg.sender == downBettor);
    require (now > (firstBetTime + 1 day));
    if (upBettor == address(0){
      payout = downBet;
      reset();
    } else {
      require (now > (secondBetTime + 1 day));
      require(!upWon());
      payout = payout();
      reset();
    }
    msg.sender.transfer(payout);
  }

  function reset() private {
    upBet = 0;
    downBet = 0;
    firstBetTime = 0;
    secondBetTime = 0;
  }

  function payout() private returns (uint out) {
    out = ((upBet + downBet) * 100) / 98;
  }

  // FIXME, wire to oracle
  function upWon() private pure returns (bool out) {
    out = true;
  }
}
