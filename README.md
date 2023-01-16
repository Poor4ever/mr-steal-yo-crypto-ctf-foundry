# Mr Steal Yo Crypto CTF(Foundry Version)

The [original version](https://github.com/0xToshii/mr-steal-yo-crypto-ctf/tree/implement) was created using hardhat framework from [@0xToshii](https://twitter.com/0xToshii).

**A set of challenges to learn offensive security of smart contracts.** Featuring interesting challenges loosely (or directly) inspired by real world exploits.

## How to Play

1.Install  [Foundry](https://github.com/foundry-rs/foundry)

2.Clone this repo and install dependencies

```
git clone https://github.com/Poor4ever/mr-steal-yo-crypto-ctf-foundry
git submodule update --init --recursive
```

3.Audit challenge codes, check the conditions for completing the challenge, find problems, and then write your exploit

exploit file: `src/[CHALLENGE_NAME]/Exploit.sol`

test file: `test/[CHALLENGE_NAME].t.sol` 

4.Run your exploit for a challenge

```
forge test --match-contract [TEST_CONTRACT_NAME] -vvv
```

For more challenge info, visit at mrstealyocrypto.xyz. If you want to see the solution, check the solution [branch](https://github.com/Poor4ever/mr-steal-yo-crypto-ctf-foundry/tree/solution).
