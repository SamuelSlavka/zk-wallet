// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import './verifier.sol' as verifier;

contract HeaderList{    
    // single batch of headers containing 
    // can be created by multipole zk batches
    struct Batch {
        uint256 lastHeaderHash;
        uint cumulativeDifficulty;
        uint height;
    }
 
    // list of all forks in the blockchain
    struct Fork {
        uint previousFork;
        uint previousHeight;
        uint forkHeight;
        mapping(uint => Batch) batches;
    }

    // representation of headerchain
    struct Chain {
        uint256 genesisHash;
        uint mainFork;
        mapping(uint => Fork) forks;
        uint forkCount;
    }

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

    // verifier output
    struct Output {
        uint256 prevHash;
        uint256 lastHash;
        uint number;
        uint totalDifficulty;
    }

    // verifier input
    struct Input {
        uint[2] a;
        uint[2][2] b;
        uint[2] c;
        uint256[12] input;
    }

    // transforms input to structure
    function parseInput(uint256[12] memory input) internal pure returns(Output memory) {
        // last values in first header
        uint256 prevHash = input[11];
        uint256 lastHash = input[10];
        uint256 difficulty = input[5]+input[6]+input[7]+input[8];
        uint256 number = 0;
        return Output(prevHash, lastHash, number, difficulty);
    }

    // return 0 fork if does not find anything aditional check is necessary
    // otherwise returns fork that contains at number last batch with ending hash of prevHash
    function findFork(uint256 prevHash, uint number) private returns(Fork storage) {
        for(uint i=1; i < headerChain.forkCount; i++){
            // if some fork can accept the batch at head
            if( headerChain.forks[i].forkHeight == number && 
                headerChain.forks[i].batches[ number ].lastHeaderHash == prevHash ) {
                return headerChain.forks[i];
            }
            // if new fork needs to be created
            else if ( headerChain.forks[i].forkHeight >= number &&
                headerChain.forks[i].batches[ number ].lastHeaderHash == prevHash ) {
                headerChain.forks[headerChain.forkCount+1].previousFork = i;
                headerChain.forks[headerChain.forkCount+1].previousHeight = number;
                headerChain.forks[headerChain.forkCount+1].forkHeight = 1;
                return headerChain.forks[headerChain.forkCount+1];
            }
        }
        return headerChain.forks[0];
    }

    // call zokrates verifier
    function submitBatches(Input[] memory inputs) public {
        verifier.Verifier ver = new verifier.Verifier();
        Output memory firstInput = parseInput(inputs[0].input);
        Output memory result;
        result.prevHash = firstInput.prevHash;
        result.totalDifficulty = firstInput.totalDifficulty * inputs.length;
        
        for (uint i=0; i<inputs.length; i++){
            Input memory input = inputs[i];
            verifier.Verifier.Proof memory proof = verifier.Verifier.Proof(
                verifier.Pairing.G1Point(input.a[0],input.a[1]),
                verifier.Pairing.G2Point(input.b[0],input.b[1]),
                verifier.Pairing.G1Point(input.c[0],input.c[1])
            );

            // hash has to be at least under maximum target refs https://en.bitcoin.it/wiki/Target         
            Output memory output = parseInput(input.input);
            if(output.lastHash > 0x00000000FFFF0000000000000000000000000000000000000000000000000000) {
                require(ver.verifyTx(proof, input.input));
                

            
            }
        }
        Fork storage fork = findFork(result.prevHash, result.number);
    }
}
