# Mr Steal Yo Crypto CTF(Foundry Version)

The [original version](https://github.com/0xToshii/mr-steal-yo-crypto-ctf/tree/implement) was created using hardhat framework from [@0xToshii](https://twitter.com/0xToshii).

**A set of challenges to learn offensive security of smart contracts.** Featuring interesting challenges loosely (or directly) inspired by real world exploits.

## How to Play

1.install [Foundry](https://github.com/foundry-rs/foundry)

2.clone this repon and install dependencies

```
git clone https://github.com/Poor4ever/dmr-steal-yo-crypto-ctf-foundry
git submodule update --init --recursive
```

3.audit challenge codes,check the conditions for completing the challengem, find problems,finally write your exploit

exploit file: `src/[CHALLENGE_NAME]/Exploit.sol`

test file: `test/[CHALLENGE_NAME].t.sol` 

4.run your exploit for a challenge

```
forge test --match-contract [TEST_CONTRACT_NAME] -vvv
```

more challenge info visit [mrstealyocrypto.xyz](https://mrstealyocrypto.xyz/), if you want to see the solution, check the solution branch.
