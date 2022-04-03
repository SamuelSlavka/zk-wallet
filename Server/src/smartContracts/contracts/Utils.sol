// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import './verifier.sol' as verifier;
import './Structures.sol';

// extract proof object from input
function createProof(Input memory input) pure returns(verifier.Verifier.Proof memory) {
    return verifier.Verifier.Proof(
        verifier.Pairing.G1Point(input.a[0],input.a[1]),
        verifier.Pairing.G2Point(input.b[0],input.b[1]),
        verifier.Pairing.G1Point(input.c[0],input.c[1])
    );
}

// transforms input to structure
function parseInput(uint256[12] memory input) pure returns(Output memory) {
    // last values in first header
    uint256 prevHash = input[11];
    uint256 lastHash = input[10];
    uint256 difficulty = input[5]+input[6]+input[7]+input[8];
    uint256 number = 0;
    return Output(prevHash, lastHash, number, difficulty);
}