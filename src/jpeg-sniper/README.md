## Description
Hopegs the NFT marketplace is launching the hyped NFT collection BOOTY soon.
They have a wrapper contract: FlatLaunchpeg, which handles the public sale mint for the collection.
Your task is to bypass their safeguards and max mint the entire collection in a single tx.

### Technical Analysis
The challenge consists of three contracts:
- `BaseLaunchpegNFT.sol`: The base NFT contract
- `FlatLaunchpeg.sol`: The wrapper contract handling the public sale
- `LaunchpegErrors.sol`: Contains error messages (not relevant for the solution)

The main focus is on the `FlatLaunchpeg` contract, specifically its [`publicSaleMint`](https://github.com/0xToshii/mr-steal-yo-crypto-ctf/blob/a240f40ba7818f6e993411e6a5e5ab3d27df2a27/contracts/jpeg-sniper/FlatLaunchpeg.sol#L34) function, which is the only state-changing function in the contract.
#### Key Components

1. **Security Modifiers**
   - `isEOA`: Ensures the caller is an Externally Owned Account
   - `atPhase`: Verifies the current phase is `PublicSale`

2. **Minting Restrictions**
   The function implements two main checks:
   - Maximum mint per address limit (`numberMinted`)
   - Total supply limit

3. **Minting Process**
   The function handles:
   - Price calculation
   - NFT minting through `_mintForUser`
   - Refund management via `_refundIfOver`
  
### Vulnerability Analysis
The contract has two main vulnerabilities:

1. **Balance Check Bypass**
   The `numberMinted` function only checks the current balance:
   ```solidity
   function numberMinted(address _owner) public view returns (uint256) {
       return balanceOf(_owner);
   }
   ```
This can be bypassed by transferring minted NFTs to another address, effectively resetting the balance.

2. **EOA Check Bypass**
   The `isEOA` modifier can be circumvented by calling `publicSaleMint` from a contract's constructor, as contract code size is zero during construction. You can read more about this [`here`](https://www.rareskills.io/post/solidity-code-length).

### Solution Implementation
The exploit is implemented in [`Solver.sol`](./Solver.sol), which:

1. Calls publicSaleMint from its constructor to bypass the EOA check
2. Mints maximum allowed NFTs
3. Transfers NFTs to the attacker address
4. Repeats until the entire collection is minted