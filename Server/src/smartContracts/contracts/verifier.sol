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
        vk.alpha = Pairing.G1Point(uint256(0x1ba4d26a725c95e6087b0f7b61476de4b033a6d09ec0ac18da851b39cdaa9b15), uint256(0x2d122f5e4de2079b43d6abd4cfc0169a1f0457f21c31bede433edb782986f13d));
        vk.beta = Pairing.G2Point([uint256(0x261df4de88636504f9422dc195fbdee596e8b5edd940339b66701dda3118ab7f), uint256(0x2e1a64a6b34af62f9c2a5c5b3f0b458472a83571815b3fff8fa87a8ba3bb3644)], [uint256(0x1ae37a96aa682153c0c003855b3ca4a21c5db544593bf65c878f390f4b62b263), uint256(0x18f4bde9473ab5616b4d4bcf6684431f02310c8124fae835b635a2a0266d4668)]);
        vk.gamma = Pairing.G2Point([uint256(0x2d6dafa89fc0218022c944856971f3e162a9a9e4460a7f64d721873fd1f4c012), uint256(0x042c1ac28154fdd31ed9bdd3d166e519594d7ff79d28321386cfb252323ef3cc)], [uint256(0x25a45b6627de437beba8ca3f2f9d20cfb05559cee9e21f7addded36c54a3ac54), uint256(0x02f1f97192bde14bfc08a654a8ca3c68ad557dbbf0279902c6f1519570ca7f19)]);
        vk.delta = Pairing.G2Point([uint256(0x0cf14fd6ad799d871eb05325d9f604818b154b9c75e6f35c66ab3fcc17d0de40), uint256(0x260f51b18614a10e4666bec86ffc0f82116914669f1b10e298ab04c91064f50c)], [uint256(0x2629973a71f0e9a5544bfce9b280909da91e7140339b83b0efe6ba1e0aed75ba), uint256(0x2cbd29e1f8e6895c40085bd166d96ca083c5b6cb621fe682ef4a88aa565f7d98)]);
        vk.gamma_abc = new Pairing.G1Point[](23);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x29010ae5907ab0ef088975cbcc193276e9ba899f8a5a67aed4f27bd59f131c67), uint256(0x14ebf7ab67ce011d5f6f6fd211b1a3d8e26840a82ffb26ef2721feff8b4581be));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2ed87c38493c43f0b004fe5769e8ea55d0ffc2934b8a9074e13e31397117905d), uint256(0x2d54f50cdb7bc103261c647cad92be928e06d0d50d3934aab7b8bf3a55a23b5b));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x12cc4218b5ba45fd64ca16b7d52e34714be2656f7b87513c4da66db0d409022d), uint256(0x21c9a36edeae15a0199b1ba88445fbba83145bbeccb44778c5ec9c9b9b475c11));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x159e812d11a57a2503443141d228cbd0ae0d2c691b7468a941e556e8662ca4ba), uint256(0x2cb5596c57960e87dd273f7d1a3fde9838a04d01d9771ce93fd8c8aa2cfb3421));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0474256438c5d8d127fafbb66433b96c6a37bba1c6011366ac9f4feb112739c1), uint256(0x1dd709deb64fb73942cc6887413db2162c80eed22beced6ca467ce02854e8679));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1dee9cd59e9ca0c9a9063349a5846fcaacc66e85d86f892b6050705471b5e7f6), uint256(0x1fcd2ac58ffdb43873f5259d78e1c26c44f5cc02d3b054cc995e682a0c016711));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x24d6be9249a60e5b7d33d1fbe08a8c901b0aa6511560b9cbf9d2a50c5ab0821b), uint256(0x24046f4ed191b3dfecf946f0578115f1af31dba3e8287cc0ecd74cadbd74ab82));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x244cbbfa11c415267187e0245373cb8f9718543f361d175d23818af850ad22b5), uint256(0x0a62d9b7302736eb4c8ec7f5ca902565aea6ebd88c9d3465359e58cabdae5ad4));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x153062d1ad1335d1a4d8ee95d05b9477a49864d93631c3d0db4ce388e4db8934), uint256(0x1b2656a514684b7cfcf28f214aa5154da6946c4db8397344e9628871634f30d6));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x180a3a5a8b8bac5f767f72527237d3a169b1c58c822fdfd7dd86757395bddc2d), uint256(0x2ebc6dea02088f9e9529c6c415722c79e22d9411e70d5951d51ed18cae8c5f19));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x07e11807dd8b7809bb91e78c9179fef4f77a3202505546f3396bc28f3bdab66b), uint256(0x1c5350e693ea101c15af29648c85fd81a8e35617755a500647d5caa4b818582a));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x050f43f5bba55225d0e45bf9da52b26cd103363d3e0b1cbb4800223559e78339), uint256(0x041b1d45ea84b13b4db0679d1063237be3ed0cf9788aaf46b7bebf26cd2b05a1));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x15ccec17f1e575161faad3e7bec380c1898999f9d212c3356e0da799afd57f8b), uint256(0x12daf8d1bdc8f8f8c93446070e6ac0f23f5ab01b96d3e7da9b33f993261b5355));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x046a98e9ca2b53ff1d6fbd42d919031cfb0d4e0ae69c5b6e797a7b37dfa8f2de), uint256(0x17b83da8df9c27fcc46eb8e89d4376f11da8a76c53b1cc4a8ce3efe154e0edf4));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x028a27b2e22089bdfc371422dfc285c65c964eb1a83db07dac6a4726bb4318e6), uint256(0x06408daa8e52a3a891e109b5b3e0e418f0106678b038bb0a46b9a7f539644c75));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x11c36fd6c078314647f0a317988d8d4c767c3658be90e4ff9d76236fef89ddb2), uint256(0x25a0e90d2b81139a1f89e49fc79bf430ead52f15f3b0f8d0de4d620f249bb7b0));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x0484b0af262da6088ddcab829ebd21c5b9387615c2e75f46766ba45c6fc8cc30), uint256(0x08ef273962a77f406311290182de2350c2d44bf61c1df843b1d708e43bdc7849));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2acf807250b0bde647d18227649dd33a2380354baee91ba66763c08eb2c3463a), uint256(0x26848434214ecc8e0e84d90959094b5f03f885439c8a8371cae159648dd1e1f6));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x0159d5eb01bdc0f1674b647082165db3a33a6323ad934513de562558b54fae92), uint256(0x13bdc7d7e9706f2aa30cea34076d8e7e4eed037d246cecce68c79b6db563a9b5));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x18b7bd529418d698ba15c31eb1669f794a7aa9a6acec1ab7b1f9fe67ba31ae73), uint256(0x141024795d6b3845d6e4b0b9d97073b369d1b8f75305474854f8ee42d6736d6e));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0a3aca54b8d432d63d9526ecca45113a12db4209e5530973b831f574ffa8f3ba), uint256(0x2ff459a19d4990c87f1b48ebc9795ea58161e5cf6ef6d959c83cf67e38e0b070));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2a0cc9f27a47034f7e5793fe8c12d9bd0a579a3aee24f52a0497eae3a86e60aa), uint256(0x23011bbdf1a8ea922d2c71e734e443cd8999ac88af4ce06bb699eef4d7fad0c1));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x08485bf660a7fdf344a48121a2a55b9918eac795cd1d4f95cd92be16f14b3a10), uint256(0x2fcfd1a7ca0682cc15c7a7f34e2704a4d17870c2ba588c299f28a9686d13f813));
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
            Proof memory proof, uint[22] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](22);
        
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
