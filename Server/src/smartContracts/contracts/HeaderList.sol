// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import './verifier.sol' as verifier;
import './Utils.sol' as utils;
import './Structures.sol';

contract HeaderList{
    Chain headerChain;
    /// @dev Create new blockchain.
    constructor() {
        // init headerchain with btc genesis
        headerChain.genesisHash = 0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f;
        headerChain.mainFork = 0;
        headerChain.forkCount = 1;
        headerChain.forks[0].forkHeight = 0;
        headerChain.forks[0].previousFork = 0;
        headerChain.forks[0].previousHeight = 0;
        headerChain.forks[0].batches[0].height = 0;
        headerChain.forks[0].batches[0].cumulativeDifficulty = 1;
        headerChain.forks[0].batches[0].lastHeaderHash = headerChain.genesisHash;
    }

    /// @dev Find fork contining hash at number or create a new one.
    /// @param prevHash Hash that we search for.
    /// @param number Start height.
    /// @return uint256 Fork Id.
    function findFork(uint256 prevHash, uint number) private returns(uint256) {
        // return 0 fork if does not find anything aditional check is necessary
        // otherwise returns fork number that contains at number last batch with ending hash of prevHash
        for(uint i=1; i < headerChain.forkCount; i++){
            // if some fork can accept the batch at head
            if( headerChain.forks[i].forkHeight == number && 
                headerChain.forks[i].batches[ number ].lastHeaderHash == prevHash ) {
                return i;
            }
            // if new fork needs to be created
            else if ( headerChain.forks[i].forkHeight >= number &&
                headerChain.forks[i].batches[ number ].lastHeaderHash == prevHash ) {
                headerChain.forks[headerChain.forkCount+1].previousFork = i;
                headerChain.forks[headerChain.forkCount+1].previousHeight = number;
                headerChain.forks[headerChain.forkCount+1].forkHeight = 1;
                return headerChain.forkCount+1;
            }
        }
        return 0;
    }

    event Log(string message, uint256 someNum);

    /// @dev Verifies array of batches and appedns them to storage.
    /// @param inputs Array of inputs containing proof and zok argument.
    /// @param startHeight Start height og batch.
    /// @param endHeight End height of the batch.
    function submitBatches(Input[] memory inputs, uint256 startHeight, uint256 endHeight) public {
        verifier.Verifier ver = new verifier.Verifier();
        Output memory firstInput = utils.parseInput(inputs[0].inputs);
        Output memory lastInput = utils.parseInput(inputs[inputs.length-1].inputs);
        Output memory result;
        result.prevHash = firstInput.prevHash;
        result.totalDifficulty = firstInput.totalDifficulty * inputs.length;
        result.lastHash = lastInput.lastHash;
        result.number = endHeight;
        
        // batch height
        uint256 forkNumber = findFork(result.prevHash, startHeight-1);
        
        // batch difficulty
        Fork storage fork = headerChain.forks[forkNumber];
        uint256 currentHash = fork.batches[fork.forkHeight].lastHeaderHash;

        // check that all inputs are vailid and in a chain
        for (uint i=0; i<inputs.length; i++){
            Input memory input = inputs[i];
            verifier.Verifier.Proof memory proof = utils.createProof(input);
            
            Output memory output = utils.parseInput(input.inputs); 
            // must have at least under maximum target refs https://en.bitcoin.it/wiki/Target         
            require(output.lastHash < 0x00000000FFFF0000000000000000000000000000000000000000000000000000);
            // verify batch correctness
            require(ver.verifyTx(proof, input.inputs));
            // verify that batches form chain
            require(currentHash == output.prevHash);
            currentHash = output.lastHash;
        }
        
        // store all input batches as single cumulated batch
        fork.forkHeight = result.number;
        fork.batches[fork.forkHeight].lastHeaderHash = result.lastHash;
        fork.batches[fork.forkHeight].height = result.number;
        
        // set cumulative diff
        // if the batch is not first, set it to its' diff + previous batch diff
        if(fork.forkHeight > 1) {
            fork.batches[fork.forkHeight].cumulativeDifficulty = 
                result.totalDifficulty 
                + fork.batches[fork.forkHeight-1].cumulativeDifficulty;
        }
        // else if the batch is first and continues from another branch
        else if ( fork.previousHeight > 1) {
            Fork storage prevFork = headerChain.forks[fork.previousFork];
            fork.batches[fork.forkHeight].cumulativeDifficulty = 
                result.totalDifficulty 
                + prevFork.batches[fork.previousHeight].cumulativeDifficulty;
        }
        
        // update main fork if current has more difficulty
        if(headerChain.mainFork != forkNumber) {
            Fork storage mainFork = headerChain.forks[headerChain.mainFork];
            if(fork.batches[fork.forkHeight].cumulativeDifficulty > mainFork.batches[mainFork.forkHeight].cumulativeDifficulty) {
                headerChain.mainFork = forkNumber;
            }
        }
    }

    event ClosestHash(uint256);

    /// @dev Returns closest hash to given height.
    /// @param height Requested block height in blockchain.
    /// @param forkNumber Forknumber to search in initially should be 0.
    /// @return uint256 - Closest block hash.
    function getClosestHash(uint height, uint forkNumber) public returns (uint256) {
        Fork storage mainFork = headerChain.forks[forkNumber];
        if(height > mainFork.forkHeight) {
            height = mainFork.forkHeight+1;
        }

        for( uint i = height; i>=0; i--){
            // if reached some hash return it
            if(mainFork.batches[i].lastHeaderHash != 0){
                emit ClosestHash(mainFork.batches[i].lastHeaderHash);
                return mainFork.batches[i].lastHeaderHash;
            }
            else if(i == mainFork.previousHeight){
                // if reached previous fork continue searching in it
                return getClosestHash(mainFork.previousHeight, mainFork.previousFork);
            }
        }
        // not found
        emit ClosestHash(0);
        return 0;
    }
}
