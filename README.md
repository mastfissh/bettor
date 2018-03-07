# bettor

Exposes Four functions:

BetUp: accepts N*1.01 ether from Bob
Marks Bob as betting N ether on Up outcome

BetDown: accepts M*1.01 ether from Jane
Marks Jane as betting M ether on Down outcome

WithdrawUp:
If not called by Bob, do nothing
if timeout has not elapsed, do nothing
If timeout has elapsed and only Bob has bet, return Bob's money
If timeout has elapsed and Jane has bet and Bob has bet, and outcome is Up, give payout to Bob
If timeout has elapsed and Jane has bet and Bob has bet, and outcome is Down, give any remainder to Bob

WithdrawDown:
If not called by Jane, do nothing
if timeout has not elapsed, do nothing
If timeout has elapsed and only Jane has bet, return Jane's money
If timeout has elapsed and Jane has bet and Bob has bet, and outcome is Down, give payout to Jane
If timeout has elapsed and Jane has bet and Bob has bet, and outcome is Up, give any remainder to Jane

-----
Payout is min(M, N) * 2 . Remainder is M+N - payout.

Note the 1% fee going to contract owner.


Cooling off period? 1 hour window to both place bets, then locked in, then payout is determined after another hour?
