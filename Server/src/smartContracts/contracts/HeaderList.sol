// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import './verifier.sol' as verifier;

contract HeaderList {
    address public validationContract;
    uint private headerchainTop = 0;

    constructor(address validatorAddress) {
        validationContract = validatorAddress;
    }
    // batch containing last header hash and total difficulty
    struct Batch {
        uint256 lastHeaderHash;
        uint256 totalDifficulty;
    }
 
    // list of branches navigated by bloc number
    struct Branch {
        uint256 totalDifficulty;
        mapping(uint => Batch) batches;
    }

    // list of all headers defined by their number
    mapping(uint => Branch) private branches;

    //validation output
    struct Output {
        bool result;
        uint256 lastHash;
        uint number;
        uint totalDifficulty;
    }

    function validateProof(string memory zokratesInput) public {
        // hash has to be at least under maximum target refs https://en.bitcoin.it/wiki/Target
        Output memory output = callValidatorContract(zokratesInput);
        if(output.lastHash > 0x00000000FFFF0000000000000000000000000000000000000000000000000000) {
            Branch storage branch = branches[output.number];
            
            if(output.result) {
                branch.batches[output.lastHash] = Batch(output.lastHash, output.totalDifficulty);
            }
        }
    }

    function callValidatorContract(string memory zkInput) private view returns(Output memory) {
        require(verifier.Verifier.verifyTx(zkInput));
        return Output();
    }

    function appendBatchr(Batch memory batch) public {
        
    }

    function getLatestHash() public {  
    }
}
