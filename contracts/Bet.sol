pragma solidity ^0.4.18;
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.5.sol";
// https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
contract Bet is usingOraclize {

  address public owner;
  address public upBettor;
  address public downBettor;
  uint public ownerPayout;
  uint public upBet;
  uint public downBet;
  uint firstBetTime;
  uint secondBetTime;
  bool public wentUp;
  bool public withdrawReady;
  uint public EURGBP;
  uint public fees;
  mapping(bytes32=>bool) validIds;
  
  event LogNewOraclizeQuery(string description);

  event Log(uint log);

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
      //require(now>(firstBetTime + 7 day));
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
      updatePrice();
      scheduleUpdatePrice();
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
      updatePrice();
      scheduleUpdatePrice();
      secondBetTime = now;
    }
  }

  function WithdrawUp() public {
    uint payout = 0;
    require(msg.sender == upBettor);
    // If no-one matches the bet in a day, lets you withdraw
    //require (now > (firstBetTime + 1 day));
    if (downBettor == address(0)){
      payout = upBet;
      reset();
    } else {
      require(wentUp);
      require(withdrawReady);
      payout = getPayout();
      reset();
    }
    msg.sender.transfer(payout);
  }

  function WithdrawDown() public {
    uint payout = 0;
    require(msg.sender == downBettor);
    //require (now > (firstBetTime + 1 day));
    if (upBettor == address(0)){
      payout = downBet;
      reset();
    } else {
      require(!wentUp);
      require(withdrawReady);
      payout = getPayout();
      reset();
    }
    msg.sender.transfer(payout);
  }

  function reset() private {
    upBet = 0;
    downBet = 0;
    firstBetTime = 0;
    secondBetTime = 0;
    upBettor = 0;
    downBettor = 0;
    withdrawReady = false;
    fees = 0;
    EURGBP = 0;
  }

  function getPayout() private returns (uint out) {
    uint temp = ((upBet + downBet - fees) * 98)/100;
    // uint temp = (this.balance * 98)/100 ;
    out = temp;
  }

  function __callback(bytes32 myid, string result) public {
      require(validIds[myid]);
      require(msg.sender == oraclize_cbAddress());
      if (EURGBP == 0){
        LogNewOraclizeQuery("first callback");
        EURGBP = parseInt(result, 4);      
      } else {
        LogNewOraclizeQuery("second callback");
        if (EURGBP > parseInt(result, 4)){
          wentUp = true;
          withdrawReady = true;
        } else {
          wentUp = false;
          withdrawReady = true;
        }
      }
      delete validIds[myid];
  }

  function updatePrice() private {
    uint fee = oraclize_getPrice("URL");
    if (fee > this.balance) {
        LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
        LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        fees = fees + fee;
        bytes32 queryId =
            oraclize_query("URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP");
        validIds[queryId] = true;
    }
}
  function scheduleUpdatePrice() private {
    uint fee = oraclize_getPrice("URL");
    if (fee > this.balance) {
        LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    } else {
        LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        fees = fees + fee;
        bytes32 queryId =
            oraclize_query(120,"URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP");
        validIds[queryId] = true;
    }
  }
}
