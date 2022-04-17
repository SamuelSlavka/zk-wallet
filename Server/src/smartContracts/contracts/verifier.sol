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
        vk.alpha = Pairing.G1Point(uint256(0x057e18588d2078319a6063e5ddc1efc4937b89a8f72f6ff21dfe4ce2e2574698), uint256(0x28fb819c0016c93962dd23fd64fc180685f12a6751909ef4f45563f09724b7d0));
        vk.beta = Pairing.G2Point([uint256(0x1d4454b48bc92b8a3d82b17f8bd45644d8d15968d41f28a0359293336c44fc14), uint256(0x13c96e282d174cb7a5557cbf0d69f01be9047b961f3734020d3cb59bfee24e67)], [uint256(0x126b99cfd41d9e75f13211863a4ebb490fd5f7a11681a16c0cf0d5302c94cbb7), uint256(0x0ea69874a5fb53174f94dd95f75c5c3957edc3c333444cb984fb24866c562e7d)]);
        vk.gamma = Pairing.G2Point([uint256(0x2e89c69436db7130848c87b2ae6110f704ea1b988145640ac4612e4b1b756bd1), uint256(0x2e5edeedbd4b8419519f36e7d7053b6c657f8b7f617faed260131b30897ec0b6)], [uint256(0x026aadcea641ec628329eb23bd583cb16c6db6acc69e92980b58fb83403c5a4e), uint256(0x0514ec6ac9f15438bbe63402a42b4a0bde630e8b42dc954e6540853afdd6b6c6)]);
        vk.delta = Pairing.G2Point([uint256(0x16a00c9c93da108b07038dfb62319cde5c4ab211cf78fc09405017c3db759474), uint256(0x01c3b58dc69b58ee7817a3dc19692260e968277c57055a63d3d432d777ff4d15)], [uint256(0x19f7b2fcedce92e29108fe87a78f7d325d5f1aef241ce481cd2a0cda70dbe333), uint256(0x0257c65c51c0d25fa29337463ff6272ac00dbfcd3b5f63c5ce93ced58b60e281)]);
        vk.gamma_abc = new Pairing.G1Point[](9);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2de975da3714a3cd2a7a1bd076074831094fa1fde40d447e5200771436d21a18), uint256(0x2ece450becd1a4bb94626bb27a1e5410e5db587dbd62ea8584d37172ca52f95e));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2c1e79ebebf4ed6f8010c5d2f1d66f98acaf231d9eb6dbab3b73e847648459e3), uint256(0x028696bb64a2a06ba39515774dee0393b6e8a5fb6ef49a17a4c3d8713779183e));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x194b07f43ad3d854a72c4e1850a7db33a20fefaf520911228ec18c2c76230d52), uint256(0x2677635eefccf562cee391bd9ceebab10ebb5ddd89b4e3fd53de3ee23414b2c5));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1a395afb40d70c0e9cdec1956130d96751f5acd1dac3f5d1d94b53d0ce12777a), uint256(0x2791d6699abbba4a46dea317d999e8f52fbcb69a78ff6629e9a4c9e1a88d285f));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x242f728789257a326a0b3ca1bcbd73b08995f7c509f41483a8cf92074d2b765f), uint256(0x01ec0522073fc61251aa364da08f97ab6a6ed89d23ca10bb70b3b09c7489314e));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x05ea1459e2f4e8b58e0c4a03571cd03430eac98029af68dbd7cddaf6288cf14b), uint256(0x2d8f11d8b0e0190158d7fca8fba9826efaecebf20751b313286b3061ca5dd72b));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x15ee65e419e488991bb972e20836d4184c1bc352c5892abe0906100c2b71e030), uint256(0x2bbe5a9b217a158cad50ecc8a27fb2c8b756e1a0cf5a4f9947675a649cb28eeb));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x08bae2235f1ed7993d80357a15ca80f21ed5e60117153cc9e13a17b2b3340467), uint256(0x0bdde946d7d66527fb4ad582e61b3d2722c7423a3489d3e63ec50b55c150bf83));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1de3504fdbecc7c424f1b8d4b6e05faa38c4d26b38d58140ea5887788dd06a87), uint256(0x0e7029a4a87cfc5fba6237b27fdfc851c89083f1202dd52e05b2784a5ddf36a1));
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
            Proof memory proof, uint[8] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](8);
        
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
