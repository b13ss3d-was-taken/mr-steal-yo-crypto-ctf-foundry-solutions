# Mr Steal Yo Crypto CTF

**A set of challenges to learn offensive security of smart contracts.** Featuring interesting challenges loosely (or directly) inspired by real world exploits.

Created by [@0xToshii](https://twitter.com/0xToshii)

## Play

Visit [mrstealyocrypto.xyz](https://mrstealyocrypto.xyz)

Primer & Hints: [degenjungle.substack.com/p/mr-steal-yo-crypto-wargame](https://degenjungle.substack.com/p/mr-steal-yo-crypto-wargame)

Note: main branch includes solutions, run <code>git checkout implement</code> to see problems without their respective solutions

## Foundry Instructions

1. Install foundry: [foundry-book](https://book.getfoundry.sh/getting-started/installation)

2. Clone this repo and install dependencies
```console
forge install
```

3. Code your solutions and run the associated test files
```console
forge test --match-path test/challenge-name.sol
```

### Rules & Tips
- In all challenges you must use the account called attacker (unless otherwise specified).
- In some cases, you may need to code and deploy custom smart contracts.

### Writeups
1 [Jpeg Sniper](./src/jpeg-sniper/README.md)
2 [Safu Vault](./src/safu-vault/README.md)
3 Game Assets
4 Free Lunch
5 Safu Wallet
6 Tasty Stake
7 Freebie
8 NFT Bonanza
9 Inflationary Net Worth
10 Governance Shenanigans
11 Bonding Curve
12 Flash Loaner
13 Safu Swapper
14 Side Entrance
15 Malleable
16 Extractoor
17 Opyn Sesame
18 Degen Jackpot
19 Fatality
20 Safu Lender