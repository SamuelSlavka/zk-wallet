// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import './verifier.sol' as verifier;
import './Utils.sol' as utils;
import './Structures.sol';

contract HeaderList{    
    Chain headerChain;
    constructor() {
        // init headerchain
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

    // return 0 fork if does not find anything aditional check is necessary
    // otherwise returns fork number that contains at number last batch with ending hash of prevHash
    function findFork(uint256 prevHash, uint number) private returns(uint256) {
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

    function helloWorld(string memory str) pure public returns (string memory) {
        return str;
    }

    // call zokrates verifier
    function submitBatches(Input[] memory inputs) public {
        verifier.Verifier ver = new verifier.Verifier();
        Output memory firstInput = utils.parseInput(inputs[0].input);
        Output memory lastInput = utils.parseInput(inputs[inputs.length].input);
        Output memory result;
        result.prevHash = firstInput.prevHash;
        result.totalDifficulty = firstInput.totalDifficulty * inputs.length;
        result.lastHash = lastInput.lastHash;
        result.number = lastInput.number;
        
        // batch height
        uint256 forkNumber = findFork(result.prevHash, result.number);
        // batch difficulty
        Fork storage fork = headerChain.forks[forkNumber];
        uint256 currentHash = fork.batches[fork.forkHeight].lastHeaderHash;

        // check that all inputs are vailid and in a chain
        for (uint i=0; i<inputs.length; i++){
            Input memory input = inputs[i];
            verifier.Verifier.Proof memory proof = utils.createProof(input);
            
            Output memory output = utils.parseInput(input.input);
            // must have at least under maximum target refs https://en.bitcoin.it/wiki/Target         
            require(output.lastHash > 0x00000000FFFF0000000000000000000000000000000000000000000000000000);
            // verify batch correctness
            require(ver.verifyTx(proof, input.input));
            // verify that batches form chain
            require(currentHash == output.prevHash);
            currentHash = output.lastHash;
        }
        
        // store all input batches as single cumulated batch
        fork.batches[fork.forkHeight+1].lastHeaderHash = result.lastHash;
        fork.batches[fork.forkHeight+1].height = result.number;

        // set cumulative diff
        // if the batch is not first set it to its diff + previous batch diff
        if(fork.forkHeight > 1) {
            fork.batches[fork.forkHeight+1].cumulativeDifficulty = 
                result.totalDifficulty 
                + fork.batches[fork.forkHeight].cumulativeDifficulty;
        }
        // else if the batch is first and continues from another branch
        else if ( fork.previousHeight > 1) {
            Fork storage prevFork = headerChain.forks[fork.previousFork];
            fork.batches[fork.forkHeight+1].cumulativeDifficulty = 
                result.totalDifficulty 
                + prevFork.batches[prevFork.forkHeight].cumulativeDifficulty;
        }
        
        // update main fork
        if(headerChain.mainFork != forkNumber) {
            Fork storage mainFork = headerChain.forks[headerChain.mainFork];
            if(fork.batches[fork.forkHeight].cumulativeDifficulty > mainFork.batches[mainFork.forkHeight].cumulativeDifficulty) {
                headerChain.mainFork = forkNumber;
            }            
        }
    }
}
