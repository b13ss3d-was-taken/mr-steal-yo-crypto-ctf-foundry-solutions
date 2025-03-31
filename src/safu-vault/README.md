## Description
Safu Labs has just released their SafuVault, the `safest` yield generating vault of all time, or so their twitter account says.
Their SafuVault expects deposits of USDC and has already gotten 10,000 USDC from users.
You know the drill, drain the funds (at least 90%). You start with 10,000 USDC. 

This challenge is inspired by this attack: [Grim Finance Rekt](https://rekt.news/grim-finance-rekt)

### Technical Analysis
The challenge consists of two contracts:
- **SafuVault.sol**: The main vault contract that accepts USDC deposits and mints shares to users
- **SafuStrategy.sol**: The yield strategy implementation that manages the vault's funds

#### Key Components
- The vault accepts USDC deposits and mints proportional shares to depositors
- Users can withdraw their funds by burning their shares
- The vault transfers funds to the strategy which manages investments
- The `depositFor` function allows depositing on behalf of other users
  
### Vulnerability Analysis
The contract has two main flaws:

1. **Lack of Reentrancy protection**
   The `depositFor` function doesn't apply a reentrancy protection, which is weird because the `deposit` function does:
   ```solidity
   function depositFor(
        address token, 
        uint256 _amount, 
        address user
    ) public { ... }
   ```
   
2. **Lack of `token` address validation**
   The `depositFor` function accepts any token address parameter without checking if it's the expected USDC token. This allows any user to specify any address they want, even if it's not an ERC-20 token as long as it implements a `transferFrom` function.

3. **Manipulation of share price**
   Each time funds are deposited into the vault, the share price changes. By repeatedly depositing and manipulating the funds in the vault, we can artificially inflate the value of our shares.

### Solution Implementation
The exploit is implemented in [`Solver.sol`](./Solver.sol), which:

1. Sets a number of cycles to execute the exploit. The higher the number the better.
2. Calls `depositFor` with our contract address as the token. This call will make the SafuVault contract call the `transferFrom` function.
3. Inside this `transferFrom` function we:
   - Check the vault's balance
   - If the vault has reached our target amount (20,000 USDC), we exit the loop
   - Otherwise, we transfer USDC to the vault and call `depositFor` again, exploiting the reentrancy
4. After the reentrant calls are finished, we withdraw all the funds using our artificially inflated shares
5. Finally, we transfer the drained USDC to the attacker

This exploit allows us to manipulate the share calculation and drain almost all funds from the vault.

### Test File Solution
To solve the challenge in the test file [`2-safu-vault.sol`](../../test/2-safu-vault.sol), the following code was added to the `testChallengeExploit` function:

```solidity
// deploy attack contract
Solver solver = new Solver(address(safuVault),address(usdc));
// transfer USDC to the vault
usdc.transfer(address(solver), 10_000e18);
solver.solve();
```

This code deploys our exploit contract, transfers our USDC to it, and calls the `solve` function that executes the entire attack sequence.