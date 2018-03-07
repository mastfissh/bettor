var Bet = artifacts.require("Bet");

var account_one = "0xf17f52151EbEF6C7334FAD080c5704D77216b732";

var account_two = "0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef";


async function doStuff(){
  let value = web3.toWei(1, "ether")
  let instance = await Bet.deployed()
  let out
  // console.log(instance)
  // out = await instance.BetOnUp({
  //   from: account_one,
  //   value: value
  // });
  // 
  out = await instance.WithdrawUp({from: account_one})
  console.log(out)
}

module.exports = function(callback) {
  let main = async function(){
    await doStuff()
    callback()
  }
  main() 
}

