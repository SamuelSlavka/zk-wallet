// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x19fb9e060acdd775637d5d2a54000d9bc48397218beebc75f6e811d2e4808d6a), uint256(0x14ba600657508c0a137b748b2e74d49083677c6487ef99a87024c8bea114ff5c));
        vk.beta = Pairing.G2Point([uint256(0x00cbdaa5b0bf312c08d0711cc07fed613f219f2bc595deff871920871b76cd94), uint256(0x241a5efc873b065af01ac08391911cd8ad4640c9bf93c33f8b7757d8847c611e)], [uint256(0x0359c9ca56757a685cad3dbd4a3df81c80828013aee9d50cc167a0e2e0f431b6), uint256(0x2044e861ba5edbb1e2631163485cbe46a856f9ed835e7388871947018dd7222f)]);
        vk.gamma = Pairing.G2Point([uint256(0x20decb7cdd5d4945a6ff0e058fe60a783d9b58f4ddef577f455a099e80b0bbe0), uint256(0x0a358ebb6cfbbed1ca3edf19a86b1a56a3a3ed7e18a8774240c3666c9f140055)], [uint256(0x2e003ed7e766dbc0102b289d80f8358eff4c337b1253f965644644f3a21683c8), uint256(0x18511521c7b36400cb4fa3f0b8e93bbb733cebc8dd1ad92eac4ff19d179c5e69)]);
        vk.delta = Pairing.G2Point([uint256(0x11c29248cb8756db2fb0d31e2df7ea94a84d36063d54d1f5cdb33483958e5599), uint256(0x01ccbb8de226d63b9613aa5b8a24706f9fa0893bdca59b12537f4c025eb79c59)], [uint256(0x14cb9bc7dd6a9ce0290c6d8e942316ecfd735a3445ab940f6cd654521996bbc0), uint256(0x1ccd5fd0868db621e03e1c46b276130f644c30ceaf738f704e933d318d838357)]);
        vk.gamma_abc = new Pairing.G1Point[](13);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0b29a04ada26f87db015b78ca93de62b30629508a00c702510c8060630e0f53f), uint256(0x10c4b15b3a0632233cd1d1dab30a9cd1b15b16f44e9a4ad7ad50f80921d39ce9));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x044a3fc4f27030ddf84e7a2c104ec3959071582eda9d360ad38840af07950b83), uint256(0x1505bfeac90f22623bdbe0d415fe96db3e6f164b93d219568e869a260f070187));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2821125b53af7407b79c428f3dbde42999efb09a84750e4ff77dee782115e4fd), uint256(0x003fdaab1f06a5a4a145fcada9e7f5efe812e0f821f346e4c189eda1a81a8639));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x23d7d4bb4a046717089cb89308ee1d69c7be720a5c53f8948b995f3dd3ef8ac5), uint256(0x02f9598c3965584d4e2a95e84a6d376776760e1865610ca0b4eee4d6d12a2fff));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x045ce86716f3f0ca7f4a4688f3940367192a2a9b7aad03e42feb8faa69e3aefc), uint256(0x2a3d940bdd42d59bb6b82f277e8eb735de2166d7df828812dde74c71bb3f5594));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x11fa6c167bd2434f00f198427d4bc67200076a30866cb290bd043815f71ccb0f), uint256(0x00e299d2f95b7016229b9a6fa1b0277ba807bdfc10f2a43dcaaa3abdd7e64a9d));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2ae84bb815b144683722371f6b0d7533b4b396c7d5f9523c13586e724bdb2b07), uint256(0x2facce6092e636878f7c61944054106a45a017c6dd40d28f7b79ef065fbbe22a));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x11623f61d5d3c0b07dbee5d18ecbb316c6597b9c91052a8e943190b844148c49), uint256(0x123aa095c1457255c6660d4a8d3f4866b69b84607a0b25510357f12b4545f9d8));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2b79cb24938cdf0c77c7a3ccfea3b5e62ee0e1cd8779ae910263592a6d55c130), uint256(0x2f26b51d3cde2c6cf54a0cc649a52d84b10559a312f545e123d6412feb4c90e0));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x2ad679e5e3f1084d0e3167577c3700bb7c336e5c43a1ee3f4b979c43a2328a4d), uint256(0x18ebf48b96f573b723532684fb9c53900bdd91fc3d34f5075778ec606d1a555c));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x078326902fd9580b2c4d26f7f4205706e70daa8b3215dbb262a45651cf73fdc1), uint256(0x0c061586036bca9be777ad7a2c42ba17ee3cf52856c8dee081e1b42f5aac2d2d));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x180c75ddd001675491cee680928c078f3d4cbfef16d15a755009bff879f31d87), uint256(0x02c1772e3b3e4cac988ba0be0993031bdbf95357802b5dd7fdb5551948a396a8));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1ef9a300590836372ef4098eaa477d66b7527d61c324e5d60ec8da67f19dda6d), uint256(0x0e790f06fb32a677c5e41e2e7e37251d137225ac1683a4fafd6698066d317eb0));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[12] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](12);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
