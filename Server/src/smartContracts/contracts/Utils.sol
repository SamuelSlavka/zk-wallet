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
    uint256 prevHash = input[10];
    uint256 lastHash = input[9];
    uint256 difficulty = 0x00000000FFFF0000000000000000000000000000000000000000000000000000 / (((((input[5] << 64) + input[6]) << 64) + input[7]) << 64) + input[8];
    return Output(prevHash, lastHash, 0, difficulty);
}