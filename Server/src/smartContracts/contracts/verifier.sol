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
        vk.alpha = Pairing.G1Point(uint256(0x2d54eb2a58bfdf1bda5a1fcd082dc40784f629cbd7665860c71d912661f23112), uint256(0x269fc4f3c1fa544e3d53a4c55c0480feaea6d462937fd4122566f0c6cc4f0b2d));
        vk.beta = Pairing.G2Point([uint256(0x08aad077579df87f90f58a403c0a57318a24d760943aee56830d16833a887a6d), uint256(0x2e2161eee4391572c1847d417f637492c4bed73847606134a54826ba02d62f9f)], [uint256(0x2156c7b9dab8290fb18477a4edbdc2ad041260c2ef1603217e80ec448510182c), uint256(0x0e23fc4b200f4451736cc1063de22221374ad9ebcf3fbd9fa6d3481213b65d9e)]);
        vk.gamma = Pairing.G2Point([uint256(0x18b6ebe9849e4128a09d6e876e3f18f53f9b08426391cb1beff290139008f542), uint256(0x15e09e7461fce97074716540c810b8a4a88ec7e42fe6236a17cb9c4814d8fbeb)], [uint256(0x156e2d6c459082b75b22e639a2aaeacc9b55396f25aa7539c54a64afa8185680), uint256(0x0b9d2113aae64cb85a242fab476edc9797943a6144bc47d8d9a6dfb2d959beb6)]);
        vk.delta = Pairing.G2Point([uint256(0x16e6f09dcbf325209fb95387cde23eac8532f305710f3bec23b911977829e8d6), uint256(0x0c79fc346202d58a3e961d7b02c4c231c056540b5bea582f09a2e64f2bda0dfc)], [uint256(0x2944422bfbdcd3885c115c3ebf1d0418d4f5a79f2f3eb5c78a5ec54b334123b6), uint256(0x15c78b65ba00f74ad67be38a6122fe2e52f6ee28929243455a139511d0279191)]);
        vk.gamma_abc = new Pairing.G1Point[](493);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2f546c6d6f33e782a77b19b72935ff1dd710f0c36060b82f9f65416516a18935), uint256(0x2dcf53212cc09a1c60927982da858087375d2345730c7efdc07d280d531960eb));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2860955d35c1cbe4d570224960d4a5ef2f02dea9acce9bb855cd1d137b068a79), uint256(0x0a34ae092332907f8500b08b044b318b1ab0d9c5c46b3e631e70f2c806d29618));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x162d06eb439ebc28b5c046e8ad04d23765101dfa84db7330d64c2e5a5a1fc028), uint256(0x0d8f1d8d37941b71a3e0a265aab78435c18d6b944982bcaae7bbfd0c70d9d4de));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x027c92e55360d4f7ae2399a89c6f80581a58f5ac2d780d910d7d637e519cf992), uint256(0x1734887c9c442541485315dc1a0b1cc401e2f71f46ec0a96f3895f84257f067f));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x10ed002371451b45747a1e8c856b0df068cc88f39a1a0558d58bc5b4789f4007), uint256(0x27523e43029f57407b6528eaad66bf4dfa98d7cbedea1f795f082b3796d159ee));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1f6af00d14e3b88e9a6efa287534338f6f01ee5059500db02a10628ee0a98d49), uint256(0x1f4795673734cc3aed117b2d7385c0a636a4e1687ddc8525804a1299a5213a7e));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x20448198e6eb4e70ad3bbe4d35dec0a04e26f5e280ff9ba8c7a44dafe9d36f14), uint256(0x1384ecabcca39efedd6ff09883e8d48c526aad405f888910050d27344db07278));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1d9c2eb45243452af1e9cd27c39a9cb2d4479ddef92ce8c01b8eceaa2914c1e7), uint256(0x0b7a0c274ecc12999dcee005e00534c50098123f2eaf4a81589d92d4703fed83));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2e5338234f4296ecd2f66f06121ee7306cfb8424eb09ecd5ed870799939958e0), uint256(0x1f7832a5213ad57c86ad1115469dbc0233e6d3dee0f680efe0d77ecdb200557b));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x117499dfcf641a5fcd9de54c166a357164935fae0b40a91eccd63b50863928cf), uint256(0x2e5e593f75fa49a064b03700f6314560dcf03f97333c052ec59fc00cd108317a));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0544d60024557699ad4bdb608466a92ae63d425c88b1b4e691be59d84b646e8c), uint256(0x2a061ac5b44bb2439ea63d600c507b256be9234094a1f4ab0a03290522a800f7));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2e59ba2873f4231dce00e9868c96829e5e928e9171a1c79ab0bc409663ea473d), uint256(0x0e03ed0be4c27993efe2ea18b46116813d6570a2fdc1c45062b05fd16195e394));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1159990252d8626f270af05e40808830ad9e3ac649d0665713b93ee8ac88df9b), uint256(0x11ea8506b902760c31f70aa5ab6b40ba69f1e03371e90d9af194f118e46f3ac7));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x27b1260b19cda2a9a5cada294c0815f3fd032e4d5ec8d503bb7b866a1a4c3583), uint256(0x0c37caca3ebd2f66b9b2a34e743f6eb70fdd52fed651a59ca8e8485e88569daa));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1d66def605a59f338fad9869c0edc6f5b8111c696c300d261e6edcc29fcf630c), uint256(0x2394c6728e5d8a1a14a4af9aaccbd5785d8703ca4fa488d00f39a451db4167c5));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x28d32c0bdb4cca4cad94eed194ae3e5d1ee1c45230a4fd5f7cbdb548b36a63cc), uint256(0x1c1e57f096eec8e2510bd43f10009a44ccf3d286c2f4dff2ff4f864c1436c85c));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x0307b017f1ba79587801a8de2c2587b26b381e41efa3dcf4f14c31b3ec73c569), uint256(0x04c14f72e0c83cc4111130c3df34f910a2b481dbc3fdda9bd0530ad0cd0116fa));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x21a228496132430e97c54741f40021681a043af01ceb230a80d82cd52605c5cb), uint256(0x1a027f5408bef50417822be67eef11bf251dc9899ddfc52444053f0bc166b888));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2ecb8b5184eb7b5c8e6f1789afc166382605cb1f89711bc410684d23120627a4), uint256(0x180541cc9c090378e716e0e700ea2ec03597ce57b8212327f6b8718a7e436864));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2f184aa83514c3cb7b2ae75a362cc7b3cf3fc7e2a762109f5b41cd6fa7befc05), uint256(0x0bb6c2c39ce98abdb15564bc1df618e848c588fdff4876c05889f508b0d8a0c9));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1ed27f5063fab42811ba28425499dfe1fc8f84d78330dbbf28c482a05dfe8dab), uint256(0x08d103cb3a24b9dc4e248f3bad788e5f64078d46dc17aedf612372c3f7bc6eb1));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0e4b70b8cd7aff8508edc26474bbdbc48aad246638eefc8daa7fe05da01fe269), uint256(0x08a58403fdaee749860090d691bfb14d04933561861bfe6688cc80dbdf31488d));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x28c3503bb5e672bc859c23c6e5f311ed2ff0270dcc2287a30092caece9ea154e), uint256(0x157d2a3604b4ce3f0db6a20f112d3fa3420b8ef7bc2410e40c5e99283acd4861));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0771230ded65de58524a2296b07466af2370263091167edaa4892e63e0ec014c), uint256(0x1bec9930c97a3a26ba80883c71729634938a5d90e1d10bf7cea8006658354099));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x025671f865a43bd51f8881a94324290d5c4dd011da83f91649fc46a18da83d8f), uint256(0x140574375acb0ac5d980218857c5f2387c01dfaffa172c9982e3b9b2a182e546));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1ecb13e59caf1ca6da31032e5b0a02a514aabb3fc860883eefb511435509541c), uint256(0x2001dbc5a6438f2c854347f4c712c975d3f7b335bf142039a77d1a70eb687505));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x07bee891141a0817bff73bae3343e55c43222e410bfea5c2637c43f17bc4ef8a), uint256(0x06266f1ded6448627a82ac9c650302595da7d18e946c35bf239ff20a3b5d4474));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2fa5470b3611a5edd9301a632a1b44a662cae98d64f6ae90417a42f052d692fe), uint256(0x2d528ad33dda8e3b8ebb3ef4ea960ccb3ed988ce0ba2016c3c34e0b8474eec34));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x15e9edca8fa8bd7397109a3584e764a57ffc9122861b3ca8e7514592159d0380), uint256(0x1624d2ae7657914697ddc11dbfc6c8b28606a0b25af88fdc209e57ac428d6a87));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x0987cdc60886fa061dcbabeaf9942e90080299f2c9272187ba86c0ab420343cc), uint256(0x1611d8f412df6b56878300cdd13f5af9e357e226c08987adf7d1c6c6a1cd55a7));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0e8765711162184e6b965eec4b9083c774556be7d195d99ef25a488514ee7507), uint256(0x0c2d379b482be1a82929f72d416e3346e5175ae42e45f207c960485c42109dad));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x3061a034f14d736028b0958a0771762e94e80203c3b0cee078af437f017d1cc7), uint256(0x0fabc4a073a7baa909785cb660ceaba7d438a0fb7aae43c894358c679a0f0ddd));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1e76813c5cafbaf6c6e0046e927f3dbf919de01e38808b78afde209afb188f36), uint256(0x159689c2453969d729e860119d2f295ee36297db382fe5d21c80fcd56469e655));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x11844fbb917a118a0267f9b2e7f8652b3c6befff52582b68c753a0c6b8eb6e20), uint256(0x1b4068cb751faebdbc6fc5d3e0c34feb9acc4b4e22d0446f75624ce05b945290));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x14319afd7f2933fa0b08425b82c50e72faa842ed55cd2a3e6072038bfc4595bd), uint256(0x1c2a7b78db1191e2e225f4bfdd4fad01e8727de8506a76fe5492e7baadb1641a));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x291a674ca7ce0d4afa98f88902af2143cb06e4a40fbb9b57856cda29619d26ee), uint256(0x0a27d473c58f2465d732a2f3e6aa6e70c3a8d8f1a6c9be6a6c466458da7d3e27));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x0de3d03d4843c4e09bf0e78236a571404a6698cb3dbe763e3dfc770ec68f7100), uint256(0x0298365e43fbc4b4873f70ac14a52dbe7a8931b99b5f37927173ddcd8f48033d));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x033b947963f530260908c83543da1c645ea465c6d775462ee2590a19a19d0790), uint256(0x2a9de1ed4ce955c809d43e9d75e993e8bd90f75ddb055427b431a14f80ef88d6));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x2b5720d179e472d06eaa2b81984afb9e62d72d5afdeac72f77506808bd6e6428), uint256(0x0318b1e0779efbd0543572eee6d8bf0c9cfb087f181a4d91170e39d9145fac96));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x09deb39c51d2d5bd9a42032e40c6239b2ef54f44b62e8deac55a9591ceda0314), uint256(0x14217cff633a7adc83395bbc2ecb47411aff38f8c85a00d4e931a6ca872ee500));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x083ae502436015f3eea64af01436cc8777128d889143047c9d508be07f8cc314), uint256(0x1a5a1627cc3c4d63ae1027a91145d16d9c03d5facf070494aae0392ef6e2861d));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x254c7981a5f75485b30f2c7043a7fd2ae897cb3286805a17e26c782d87a8d02b), uint256(0x225c8d5e3aefe66b84564094aac48f18daac0cdcb5fc4e4866e066c5eeea25ee));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x156292ea3359cd5a46bc52a4dac664ac5904868dd4cf20ec22ef0acaaced3e84), uint256(0x13f18ec34d43a1796e7590186c69e77dc10c1d7729bd8d50a7c3b24049a5a8d8));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x24a4411f9026aacb2bd701a4ab3248dc8d24be2c234a1d0ec3cafa631a42f682), uint256(0x2d7d31de334a476f4bdf4aa42b40f09d526de99f0280a570ac4fa2a2436b4f86));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x160104e47eef9cede64f917fe539dc3fc665ffaf6fe49c19233a355c5013e2cc), uint256(0x1a225eb4a317f40ff8be4003174b120710d3416def4c9adb1f6e277abdb3077f));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x14f2a5ab377d2190067f62f041e95381da3d7518964f421c0c3cfd0aa954caf9), uint256(0x089f19335077d0033ecc37942536b9b027f15e1866eb036b63a90839a3299055));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0241b2b7ded3ba85080426b9aa24271a3e09782544276eec57a3895c846a3a62), uint256(0x0b3f1eaec531930a9c5ce412095000a3a1daca23c2fa2f01313c3357d0fc0c94));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x1a9524cbe934d32099ac7c8417dd1ced6d4c4a10fe0256ed4df50cde9339676b), uint256(0x0cd5ac355c761597b2a573256a3ad5965ec8b73e794098da16caac5c70360e37));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x2e0b1a92af4edda0735b1c85ebeb2c4ccda476037ffdd905dfca2ee42ff30a1f), uint256(0x227b1472e177847c05b7a72016c546e4242b3efa5c87b5164a9938fe55964ccd));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x2639af4c4677c30954c047beb02a4a29f7c96c602d55b34707a1bdf0545317e7), uint256(0x1c148918b804df7be410f5a91c22aa038872e586ba9a5aa2b02558e0b5f11c2f));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x223ec9a8181e45cd71563d774f73bc742e3966f2dfda648d5e560c8ade53284c), uint256(0x2861a2414ba081fda9468ebfc00a75207db3ceafb9a7d5a442bb7207447d0196));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x10360949bb8da574737b3bea1a4848cfdb262b714f9b462dd5a2eecc15d44bac), uint256(0x2b07dbf9656b839a1feaaf7d811a4221db24830e89102a91072430e6de28b671));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x1858d1968404bc96151916752d2a59789278bb7d73b886ef8ac2d8345a6e5df2), uint256(0x2bd040c740a560c6f9af54258a333e2907a9ec88254dd46cd8825929aac920f3));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x0522b904b355235c113d6111b7158e0b2ae0cee0455421da290d9147092fd2d1), uint256(0x167af878234a503e736d38ff1de954c6931ce5ee8e3e6acbb56aeebc449723c2));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x09d288312000ec974e39f877b973fccf04a497ade43ac025e5d3029733ba9385), uint256(0x11d06b8d98d14632b54fc6278f2a4a2579326d8c0cba7b06d0faec62c2b82ba5));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x1abec32a60ebf7b05dab04fc63608d0cd42faafcfad0b015b9be6170b37dcec8), uint256(0x10c3e86fc68c5a47382662b9a46c4c51f1f47281a8578ed5f444f391a75dfe01));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x1dad37f7e9724509611d9f4c991f772f3d2820a24371b6e2fa3941d4c8ae85ac), uint256(0x1bc84aa5650c6d623f41c982f9ffddc81dff394ed02dd859a4f398ef95b822b4));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x03c2df7fe3eff5911059f8470b8b9f2e2bdcf02e7c1799ec215f5bd473caa797), uint256(0x07d2a0789cc235f5e20942f523efe6121e89897c6dcf7b8e40324ed988aa8720));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x18c89341b9184baa48a4d6f8e85581aa771da746cb53edc58e8b19ea07e40922), uint256(0x2c3e7a18e958d786950608358bba2d08fe4be1f1fd4fac4b23c62e9189fddf04));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x29cbd4b8280b8072daaec6ced3b003dfc4b83ab2c7bc3331344cf7a27fe88f6a), uint256(0x2ed5ea6a07838be3a1b2b2e2f157bd09f66b9778cd91dcee284323c6c899300a));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x240dc24d8593664cc2730ea90c72707cbcf6a4c1b7005605ebff05ec454d8b2f), uint256(0x263199d0fdf9a7575825e83a736ff2af276c9c83050bdd219620f722d862de49));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x09979544c93e4e16db6f006de3a1191e64b650e798cd0eabb4d92053afb2b2be), uint256(0x2846a63105a76b6dec47ba8aa3c0c54dd104882fc75378a578c9cdcc84ccf9d0));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x2e7e869bb8a5d0d64fbbfbd6492f27cf92a4ce423e7532f78a9d9e216b3ddd99), uint256(0x1ff14b1854fc01791e8d81089dab2b39291a72c3a8baf8771484c8b0b2ed2b41));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x059fdd19a37171715334cd09961a3b94dd4f2ef5c5d843d6fdd404f7d2edc016), uint256(0x0d4f3bf9457f529ccc240a1a086575bff6bd8431962c4ef0719bbae418936696));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x185bb6bd9cea72b505a131a972ae01b4917c3dfb2172e69baf1faf20f3ee65bc), uint256(0x2a0bc2d63cd0e6485dd9a1096043530d9eae5270062644da2caf4123da5aa4be));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x05270d0490a661f5247672d763d2c1abf3e4591273b0bfc267fe1106c2629655), uint256(0x024d9c32209e4b56655376de8cb2790dab32596aa5e6c5dc2062aa7720d3597c));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x1528a2eeb67a9d53c2d2e60d5d13f7851a95388d7c9eff37e2a9f9d0029fd28e), uint256(0x1519b08efce83910d0e9ba74e4262b82cb0cbf19acde199427742db36ded0957));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x2d05cd33c72d13c45d1c48a7416fa9be086328131e834fb2f493774bdff34023), uint256(0x2a8639cbe5c579bf1b444d1aa968b72d3f533391325a37658fe3ecd963ad5910));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x1f94e25cfe3a0aec30bc727f26ff477721871a1cb9193b54521b47594638c1ac), uint256(0x3019e85695a02d5e69699185510654f968eceb77e3dda330a18606061c829b44));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x1d4651cb67c6270e73c9cc100bf059cb00b928c0ed77a9dfc40ecf6ba2e8c890), uint256(0x21f3d7211a61e28ddb6d48f4f7fc126e83db7d1dc99e7bdcf45b207daa490ebb));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x0b1028ea2f1f40a447171df6aa093fb5e187781a5156c1798b85eb0b995bd351), uint256(0x039d48b7036788a26f70ad2a3bbea9d3f5a011a9f2952c2402517f2b01fdb37f));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x143d7aec45c564c1d84a2c8c6602886cad69924fd97096eed473719ec16a1dfc), uint256(0x000100e97d308672942f89ade044ab1a145d3ccd6b2e5f4e8704b66c3f78a03e));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x2040754e89c2c0fe89a27328bdbaf751d8f9a5aea2baddef93a4bc0c3bd9cb47), uint256(0x2a9b89fca2a7a0115e67e611c2dc5690cf825fbbbc77f504414e432db08fb6a5));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x0530181f97dd1b50d6c0547013790e75bb156408886ad5364d90b351457880f5), uint256(0x1634c3a8f5f068fe26d13b148c8286785291ec4a130ff563da0dd474f0695401));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x1842b60a5fe279b258a2d537f4f0a19b6a4f704724c7a6ee5a27108791d03b07), uint256(0x14f3fc9afddd572a06e8843757bcf1199fbf532b7eb75df2f5e96debd370e79d));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x242f60ae560bd05e2ba0db6694303a45a095d08f76db3bb2018184d30f77c052), uint256(0x19100d1f0c890c2eff191f8d4f9daedf7ebd1c29184111839952c7dfecaafd7d));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x23bd291774f8c9ff2090ca267b9fd15be4a942a107952b9184540fdd06f64740), uint256(0x24ac206bdc37e75f3b7f11b246a346a85e75aedb9b9526236dc5a6b5487f629c));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x251667e2fb80878fa942bbaac83f3d8190294d6777421014d5e67f6c9e5d6660), uint256(0x19b3198c9dc7dbd30d01a41f03bb964b1d57561eddc1cf1e739f85b3bff64335));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x0c6eb1ea3a0e18553d03a1a7be535bd4c2b734cf98047e26eb86f0520ca4ab50), uint256(0x0fc0e850fc3d3e5de9a2f99b4ac7360b879ee04c500962faa1b58c84bba5b979));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x22f7d1cde929903e46e6911cd4b4c6f9d47affb15a6706d112aa954f085b2740), uint256(0x21dde699295b6219d999fc74631b806a97fedc1686ad1a70be2debd6632b2e94));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x2178b16a882d9200dcd1004ebb19dd04cb0c634d1492e85d60284b69c2e1f296), uint256(0x2ea113fd8b0e3ac2bb96c2408246c6232afc457cf3d6e337c3ed0a46058c5ef6));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x035ec7ecc6e61ba2c1a90f2498f4723f617ddc4be771a859cd82fefc09ca1e69), uint256(0x1afd8389a7c3a85ae846825a75db5df061e44cdb901f934525ade92ea9e4b56c));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x0421b8e1df36fed5cedc4774bb2a943e768df6aa43cc832ef4463e7a3656c849), uint256(0x185e4cb937159758f948cea2ace00729047d470118a13ef2543fbe9abdad38eb));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x288d9b87263c777ec58f1855b5ac77a9e8f93e6504dd306e9c256ea2b86ed13e), uint256(0x23a93c285928a8bad56184db208f4279e687a465cf44d3b992f1a34afa359042));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x145f0d63c6d32b939bbf8758ac5ccd76c6b51d8bd6672628a321b8cf50f062e2), uint256(0x0a83ef72315f56e12a79bf000b16c397e6f71a2bb9ba957b604e745051d437fb));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x184904db0639491e95aa36186c376631ac13bd85baa8a05e1e85743e72df4592), uint256(0x1bec2135ba38d7704df2ad183b7be882776a540da7cf9d266cbb102ce6200b5f));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x2d12cea19b836482be39e106f7782c9c50407b869b3ede9304d6756834e26529), uint256(0x2cfffd92f48a1764eb7a63aabe44fea436d399b930f19cd20ca2bb770005871e));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x15fabe4627595e72074a121e5065fd63bbaf2fc0533b8cd5189df215fd77ec9a), uint256(0x249d403bce40806d162499c9672092b4bfa38605bf9f792faf4644125dbb2b72));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x2e6b674fd3dd4fce1a31c2dac48c9889ab2a5f9274e82250fe13cf77c5935690), uint256(0x13ac43d9157a5d0e7b4fafee06544c9b2e3317c0fe9151a402f22a95546d4f0e));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x0e31ecaa903da49ecdf2f8dfc82fa29d4dd97372ec5ea59b5cf3ffb7a8f5a8ec), uint256(0x2f1e1f492f917c0b12742737cad4c0ea229f2d06c6b8f7cb6af589a2a85e0e53));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x0667cd4841dcf417aa95e28ccf89b74c27dd12843c847668f67c1d609babd4d3), uint256(0x2bff96805899febc4d339734669a3a59b5b6db7771bb64d1a0b8fdb2e786b540));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x1076ba55cf99b5ce1273c2fb38a54f54e897258bbd1786f16f474a5ad9968737), uint256(0x154eab82129fe2f1e40516cacedbe497ee5fe4de695982cdb29255e1b2c07db4));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x1124ba79d4037fd0ae50451ad35a672e9bfe0f6e073fe042e803c8d735e7c382), uint256(0x2ddc38e02ec0eebb2e6a01561e802b1a40b211852f60fb62b1d5708e10c281a6));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x2091539fe897a529e231ea9c7b49f5245afb9eafa3bb66e7fcd5f92d6c102854), uint256(0x089bdc9bce0d3f51ba5cc5dea6f7ddb42676126fe6c4eb6fad29617804a57675));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x119e002f7a18c66e9eb450f077d49bb35a0e4f200b7b6986915a6d93343842a8), uint256(0x12a859b7c95f82eb28544ea17cdf7097ac026923c4cc13689fee73759c20571f));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x23208a686a2f708e7c55e8aa1891b359be4cdac63930ef5ded87856293bf3467), uint256(0x20c4548a986802423d0fc0b40d5d109f29672f06cbe270c9f21ef0904ba4dde0));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x2c32b58f2a1359787aaef51e44b2ca9191418fd29d78d3750263635f89438a11), uint256(0x12607f757379fd0d95622cdf0951c9eca15c1994faca36371633194b11b59ea7));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x08b40c4a187358c2bd32823f8bfa56563462fafa7fb75d4203367eb1db94b793), uint256(0x202ffaaaf8f74d3391f58bfd68d1cb9fa4b0e6f17596379109b7421bf70353a2));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x0518c76847c10a2f5521b852ca07075df439666f6c01a96fb675acb7abc6b7fe), uint256(0x238a5ed8b203b0b2cd304e5f47a190c291a4c59a2227cdb0785337be68d62f5a));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x02845e9a63296ab4e4872239a70536ab14f930ad558312ddcaa9f1ccdceceea4), uint256(0x2a38ee2c258a611c284c539cdfcdbe466a3a6b210092619cba4cbd25667cb0f4));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x013ec6841846cb9fd3b5e43cadf16de6167ce18479b8f7aaa32d88fa87474ac2), uint256(0x0b909fd829de206d5f6f1cfdcdad3086498ec4b65255d6a373303bbed3e7de2f));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x26453aa7fa1a25ea66f6ffce9c95650143dd8623159795a92c69467e2762e92a), uint256(0x08b4444c60e6af1c122d41211062146b7b8a165193e22c8f0b7be31bf4a7f325));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x0291739ce53a13627c1acb40dc9d9d59f57a91b15171bbfa696b6a99700b4d16), uint256(0x2ffaf46015cc42b099ceaf56e6331157a65293e7799412e08d4d8438750ab5db));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x230beea0468c594fbbecb9eacc3cc6f2505076359f674a47e1f5c5c5b4bd9a62), uint256(0x0ee41db25cdef7441070b545987ec6b56ce61acae836f33ba8b9f1935f0796f9));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x2dc3f59b3206fd9d6b89fbb4b3212bcc37009f9530d9c8f368d3942f6f0f65cb), uint256(0x1b66e3186c4e1859be1bfa62d9d84cec686f86140831b596e130e51d1679e0ea));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x1ebbdf3bbc89ce67b8b1768445d50539362002187ea9e98a3bd6570814acb507), uint256(0x16ad41a886da0015259893b74d29f5f5ad407b086f01b871df5c2364664788be));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x28e115393917d284ad51421db9bf4981a1257f2744bb4d07738c27cf41f9d3ba), uint256(0x2a43403315b2d3d08462968521d0f99f143b6a81d91cbb5dfac559394cf58cb1));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x1b291b39edff6aa830ba3550de652159d1330a7b7f2a3ab5ff6ea922b014b0f6), uint256(0x120ac6a90d2cef3dcfb905dd986649aa5a8e0ab2bc4b7b86ca50817c43a602e0));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x0a4ac6565d5f651bc9e7570d4303130ae23dac58266fbfb6a3f3f58381935e05), uint256(0x15f4b71fed990a4758a2b902ff899a8b499cfaa8206302f99e0dd1140ee59600));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x27eacdfbb74dac398b9d4350e890cfb97dc6dc39733dde2b5b5d20e84f642bc2), uint256(0x25d44fe7e8a7d59439ed8f18bf0853f4bff3468abe8dde3ff2d722143a337a94));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x09d557ae39231e3a358f22d9fbb5cf5da6c857c82f704e1ac681734f0d2a5f5a), uint256(0x01476490fcc97cd391d29dad28f670acd77119a1531a40a581332fd5b2ee453e));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x0806da93f65b5cb5ba4d5ae2514c767ec895c3ee86d2c236b926def16d38ecf7), uint256(0x1c67b56712ce00ac043673bb9a7b05d437b4e3e811e1010a576e88703621dcd2));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x306412b52f17954ba2b9ac184b3e6c10f6091330036ee8bfa4a1dbd1bc0f6c72), uint256(0x1a4a5bd872e7a70d02220f828ee673f4eb1756c0d3e30cf913bee73867ccd78c));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x0072cd08659b8a930b1171b13fec282d82093499c449515572509610eeb609a4), uint256(0x07c6d2e97d98364980da9b143767bfd34cbfd1b275839dedc041358971a3c014));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x263b0bd11df91f593eb5341c8e8194db217e5278fa3633012babbe27d802d7fd), uint256(0x00e5d8798baa788f900240c2b3a8d3a98bcf33ba358348f60798683806aabedf));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x1fd3e6261f2e101a5133386a86d747b821d7d75900e760537e957b64991457b1), uint256(0x0a158beeae061744b49634bbfb1d7d3bcd412dd5822f7395f4761d0596d3e237));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x132bf25e423089335cda1576481a40411d507412c530e82fa27e0c5607e86e18), uint256(0x2dff6faa1cdd2e8d259cdb89e4abb01b84981530246accafa740ae295317092f));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x19a3ff8260709a47dcaffe6c66dc35e2682392e91778d2f8ddd7c42f312dc1b9), uint256(0x094ffd4021e040be594d487a25c906a64e9e61eaffeeec17fae7ee15c15ba560));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x0d53b6b5a16ff045c3aab21c663612baf10c458b8511725a9228d9258ab81dba), uint256(0x08877d55ff7660dea93471f07a65a29e5301c92c55b218db626fa88727ae098e));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x2d8b048861123c8ede99d0c1ba829008f75323a858160b5ec0300909fc426d6b), uint256(0x17bb0046709a38e64750a5aeeb7bc8cd7a248fa576022d87ba58c85eb168404e));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x049185f24a6a6f853821c46b89e6b9b8a1bd10fad78eaa889366fbb29be0e3e0), uint256(0x004b8b26bc343c013fb0900da26b21fd6e5261b860aef078c69c5909b28e2755));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x272073a789570d1508ed77ed0e075851dae8a700834cfeb8be28a9039e24e957), uint256(0x05bbe6bb503e49c213799c1359167ff8f7f2dc479787cd6bd7db8cef49ae04c8));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x127208aaa311d7329fa9a8ee89f02b1442db99dec3bf0630ce3d3dfc7e6f8d00), uint256(0x21600487234d253abb5cd7b5dcf2277dbd68ec37fd7f3bb5e817381c38820f4a));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x220be5f66013bb429018a8645fcbc84647027d8150203f5b5cd8e211d7880166), uint256(0x1ceff08c49e5725f5af981827f6c734240f539e170247f39feeec608086c4892));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x2a6edfc76073d592105843e55218ae5e547a7186066b729844d102fc47a23cb1), uint256(0x2a1aca58b8aff11c825e54e47376001c214bdf3adef8ec73c969e17497daf471));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x16c29525d58f3aae390d6003804666ba6544387768dd0fbe2077d4e9f3ee6a2e), uint256(0x1cc98da96fd9294fc9967fcccab85625d6e58b1728c689f644f0dddd0f61348f));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x1f5f4cafc88249864911b16cdd892a11cc4d2ce1f16246b04d76f2166385634b), uint256(0x0c485977d6b02c2611d8dba54b6abf0715b1e15307141591751450bd0238ecbc));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x21bbc2d6768585f413dce9de29c7178aad2f6ee432aa6d5f553326eea7366ce6), uint256(0x0aca020e5694a13e27717fbdf0a7c2bb0922d89356c7b8b18a8ff08098b8a900));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x1fd225d295f9771c208b65194e81c423b8947ca1b5c20e1f6969d7c10456945e), uint256(0x0ed266bf4e1c1e2373539008eb9f9d8fe43c3b496a8f17554ce34bdddc4dbfda));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x0b9e3a71180fb10e2b530111a986da46ab68d5bb12c9b85e6ae07b9ae900b4d7), uint256(0x286561b96ba27acef91df0a9dff5a851789e76ec13515e26f86770fcb5cb80b4));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x0531b867dbce216d5a834d3c55ab093696602067206e7a5b165fde48cde7a94d), uint256(0x1a1b5dd3a0608040b7dbaac117f41a7f32f136ab0b5f4f5aa4cb92b63d1baefb));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x1b513e874fd91d548cdc2c8bd02a34fb0410271fc4d3b3fa7bd05091d203676e), uint256(0x0905d97e37c10af10c981422c5c2d44dbcb9e3708eb7bfc882458ffd246cf1eb));
        vk.gamma_abc[132] = Pairing.G1Point(uint256(0x1ce0c895c93a2a446bf9e0053d84b398b6eccc124b7c32360ccccdea21de2cf3), uint256(0x0146330c4d11949d58af7e3bcc1f67b1da7914a4665c1ff8f812fbc2bb3cdb65));
        vk.gamma_abc[133] = Pairing.G1Point(uint256(0x0e285b5628b8ce1c4d725f9496e34e22abb25047eb9a7355bebc96602ed9d56a), uint256(0x07adab1ca1ad2d4fe1307232bebb478653fc70ea808aef7f0728b1bd67c71e81));
        vk.gamma_abc[134] = Pairing.G1Point(uint256(0x0b1a05e694e4f49911eb672960c86ad7061c420448e7f0477502a43687b269f3), uint256(0x2ad00a5f93eb10e47b50b58ada20de559c8d3c3c52f2574909dd129fe34682ff));
        vk.gamma_abc[135] = Pairing.G1Point(uint256(0x00f24934f1c3e1452836076fe7f4b5ad12e366daeb0f3ad530d59d7c265546d9), uint256(0x282d0f426bbde7c9f83df24ea707109b807fd45d2dea801131eaf64f2510cc20));
        vk.gamma_abc[136] = Pairing.G1Point(uint256(0x28d5c8378ffb41b7c4da72406a1bec21efb1405f5865a1310815c98ac59dd0bb), uint256(0x2546a4a698a3dd89446ace28df82053ad14d42f74ac1ed47d43bf34941b933fc));
        vk.gamma_abc[137] = Pairing.G1Point(uint256(0x172662493fe464c200ef4a267303c7761258968706c79b19d0d277ec0ff39c87), uint256(0x1e3c619afc9f4400b82ec6a228c8a1a44f87b9cdca7b3aa31300ac12d79c86ae));
        vk.gamma_abc[138] = Pairing.G1Point(uint256(0x21a865e7422342ebb5253ecc7b8a219ab9a9e83956d952fdc27f8d9a1ba5ceda), uint256(0x28471822a1d385db9b920001d25e2e4d9fa2b2d7fecc567a47e601e89155e080));
        vk.gamma_abc[139] = Pairing.G1Point(uint256(0x02c6fc5327374c4cf379532ea572c592b63490b923294ea0670d31ce8a394712), uint256(0x1bfa554665e3b4f7d3007efab0feea2024e59e35beb33a720eedb60846270ae1));
        vk.gamma_abc[140] = Pairing.G1Point(uint256(0x2dc317bc22b2534a0587c632a6c53fe400d1fb6de5e4085b9a2b7c78bc42a9aa), uint256(0x0dcf8bdf3077073abc6089af218567916eed9c18eeffbe6b8ba80cdb274ea537));
        vk.gamma_abc[141] = Pairing.G1Point(uint256(0x1aa83a68ceea5615b6b3b736c7c84d266fbd6a2a8ae6f9db884531473142b123), uint256(0x0af1490e7ef92c97c51e9d5acedd813559e4a032da209e60e2a2d8b160b054af));
        vk.gamma_abc[142] = Pairing.G1Point(uint256(0x107aa52c9a5c01f857b1e15310cb8b180f1a76cbb6a565cf0e67c5f7ed168f6f), uint256(0x0d7a48ca883539c97a158ac8f44fc416fe1ed650ebb5e77e9662e9236260aa33));
        vk.gamma_abc[143] = Pairing.G1Point(uint256(0x0206eaf9e82c50b4c0e807e881a36486f4bb41f8ea6481df188db65c198b63bc), uint256(0x084b2b5fdc73288d806da376e0b101b61c894dd0a6ca7c567991180dd8e6ab72));
        vk.gamma_abc[144] = Pairing.G1Point(uint256(0x1ebf652b3b550c0bad5abc1b77fec8e0a1fc22d75d70d8736671c38260b1de6a), uint256(0x2a5a98fb78fae18fbb4096adf87af97951100bdff142c104e9b69139207ed357));
        vk.gamma_abc[145] = Pairing.G1Point(uint256(0x06e3edb371f22ab3a1b35b072844b4253927d3c2bd2e1a42c1f9276400061b73), uint256(0x2c90f44ff7db76e95d0deedb678e542e8d003d23fb68fb4a42c8b7bd9d1b6537));
        vk.gamma_abc[146] = Pairing.G1Point(uint256(0x2248da97213be4bf803d7cbeebf15295e8011822e57e9168830a619a3bfad14d), uint256(0x264561201afba0c461eb88255b179507334017350280ca9a474344c52f8a746d));
        vk.gamma_abc[147] = Pairing.G1Point(uint256(0x0468dfa4fadf2670bbcaa2378680d95b9558a353771a4b92217d4f2c660d4c6d), uint256(0x05a1d3bfc0adc9749fb6f9338f72248a59d6716d7ba5036c98d9e9c24caabf73));
        vk.gamma_abc[148] = Pairing.G1Point(uint256(0x2009ccf0bbd3a01a55789aa7829b38e1a54909bfdb8bf657e6502d0d9cc51d2d), uint256(0x22cd40f1e3b28128c784cbedf1a2bec59309345a528f9be6f6b1e0f4129f13a0));
        vk.gamma_abc[149] = Pairing.G1Point(uint256(0x290c42495a7583538daeae4eab351deb655249634815da3739a6717478e9e482), uint256(0x065015670eee03c6ff1ebcec6987f46d3a9e0904e2d42672a7870976a233ad50));
        vk.gamma_abc[150] = Pairing.G1Point(uint256(0x298fdd92ca56a28725265c55acb9c91bc684e210ed47137409224e96f48d9637), uint256(0x06d01ea6b6bac77025c23cef19cfb6c41f0c28351b826fa519e2a937911aa773));
        vk.gamma_abc[151] = Pairing.G1Point(uint256(0x21293ad36d61de75cb3383dd3a315d5bcb58f920b12c38af9bce35cc53f968c6), uint256(0x043eda30e98086549218dc3a5cf82fb592cec563735349f83de372709c845dd8));
        vk.gamma_abc[152] = Pairing.G1Point(uint256(0x02b3b2ec2726028e1cadb3d610a1439abe1819b169e2e818b01a34c5a9608143), uint256(0x0d0b3f9c0b7f9f69d42f94da5f5509ddf2e962c07dee2542dfaa21294f01f843));
        vk.gamma_abc[153] = Pairing.G1Point(uint256(0x1f64150237485703501c5083ce9fdb8d98191e47bb8a36e742389102d4fe4c13), uint256(0x2a7ffe0857b06dce2d1c5f8650a0e3c3bb15f362c20f0991219bfa5635b42616));
        vk.gamma_abc[154] = Pairing.G1Point(uint256(0x141e8337902092db7f678b23cfeba4e4cd7cd77621dd17da0cc156b554c47ca1), uint256(0x0612e0297b17b6fa142e9e869683ce83b909376fbf6a73edd20db46c552d6594));
        vk.gamma_abc[155] = Pairing.G1Point(uint256(0x18adf9e95870794d431e686c722d94f1b45ed9d3760ceb30def7c29ec83baf47), uint256(0x102f52bc8840e0dbdec63609f72ad74337cecd6e3cce1da20b9e3178147d0f6c));
        vk.gamma_abc[156] = Pairing.G1Point(uint256(0x15c601a05d27cb25361f177b706b060ad1795055fcff4cca1d2c00c0f7fc7d0d), uint256(0x0331598cb69aabd11fe99d8a0e3c18fba6917bd56c0faeb05bbea7c1e2c02e73));
        vk.gamma_abc[157] = Pairing.G1Point(uint256(0x0a884d651137e3da0fb2dbf35cf2c32b13be0260ba24d79a33c0108bfc0ed6c8), uint256(0x16a0acda53cd06638a201e430b151f549a8b6094b1b8808ac61f7859c55ce586));
        vk.gamma_abc[158] = Pairing.G1Point(uint256(0x05aed61cce6b91af9bc6f67e4be9e2d23fff0438e695394dfe21efbfc974fd66), uint256(0x09e811aaa35825f98af133b0cc2e6bb2204e554153b22c89a394f7741873ef78));
        vk.gamma_abc[159] = Pairing.G1Point(uint256(0x0080fe6a549fccae3aec578cf78073c904c515ff61d7a56a53176a9a3ac16573), uint256(0x2d41f0eb60b381c72f7f5065f02a91bb5928087684c835a2e8139076e4dba1b2));
        vk.gamma_abc[160] = Pairing.G1Point(uint256(0x07981bc54eb80ee97ed18508f414da7f10da98560add5f643f5f8671d0cbb6e7), uint256(0x2ebf3db7f721c7411d8f7febcbe10cf34b8aa76f0175a2aa074138371ca509ce));
        vk.gamma_abc[161] = Pairing.G1Point(uint256(0x2453cdad9f014993991ee62d86d050908dbde2c1d3372f19ec6250cf26d0324f), uint256(0x015d5a483cdc4ae96e9e464e0b59afba5e9a57efcf8fc6ec084219dd91277e83));
        vk.gamma_abc[162] = Pairing.G1Point(uint256(0x22d60574f62ea5fb87c88b1113c648fdb74012735801222c0884dcf410f805ce), uint256(0x2b42b599182b22f30ecfb407136aa59a1977d5e6f32fec806304671a31895b8f));
        vk.gamma_abc[163] = Pairing.G1Point(uint256(0x03331e090c214f5587cdd3d82fb11268250e279d57d7998fc8cb46dc2f1c60bb), uint256(0x120a0a96d0946050fd3133d7deb0137a3aa13da2c440b51393e4e17d88591da3));
        vk.gamma_abc[164] = Pairing.G1Point(uint256(0x21c779de21e1a9f82494a85edf75c6d96859b25199c7b149d22892dd1214446d), uint256(0x0ad2fa0f68383c7d166f18cfb09d556a9b164a8e067a1b17fa6c60c181bdd8d1));
        vk.gamma_abc[165] = Pairing.G1Point(uint256(0x0a959fb2a463bc80e7aeb29d9860523baf22e24f44c93cce0f5bb9e50c8e27ed), uint256(0x26af3b7cbcdd5139c112a1cb48698f4acbcbc1ad2021db4d57a4366d2a40bb23));
        vk.gamma_abc[166] = Pairing.G1Point(uint256(0x11f859c4e1d9a35b81a963316e043b539624cca0075233e370f0dd36a337bb9a), uint256(0x265236133d1c8456affc55390844454c84ef9bbaa7d235aba09d559bca73ae99));
        vk.gamma_abc[167] = Pairing.G1Point(uint256(0x242c3e162bd4af00b6bb3d5dd213c8407142b9c7c33ec4631103ac9d45093e60), uint256(0x0021649554c2161ab7ddbbe32d76d132a952923a1e004e8be2c0363d97a7ecf6));
        vk.gamma_abc[168] = Pairing.G1Point(uint256(0x1645206b0d35bd274184bacb720ef720aefcb209c901c6dd952923ec14c4fa49), uint256(0x204160687bd2b79332adf5cb6e20ef170ded0a0bbfce07b688f1158547e88b35));
        vk.gamma_abc[169] = Pairing.G1Point(uint256(0x0e1fe437cec08c5e2258255601c44b5185e3e7dc6a52628f8d56dfc0d0ccff7e), uint256(0x1b1e016290be8b794b74cae87fbc36d0860239ebf4620c08d833c9fc6507ce8b));
        vk.gamma_abc[170] = Pairing.G1Point(uint256(0x0c5f602ff092c64b792256d25f0967d7930550cfe0c80afd527a0b21fe8dd6da), uint256(0x078482b6d3d7d0bd05d83c4cb9f9cead983654a9b2e078bb218e4e8ebe1af367));
        vk.gamma_abc[171] = Pairing.G1Point(uint256(0x2739303c324dbf7d277dd53748b61ce7ee40182734058b09f5b15773a4019116), uint256(0x24a75c86d211085bbf3d3d433810c35413ca40774e5874978d39570b68746e55));
        vk.gamma_abc[172] = Pairing.G1Point(uint256(0x2656db99491d7e19ce8a9973e6b82381d5d26d98d06bc6ad47227cb95d9207e0), uint256(0x1e5e089939a7570334e6f22c04bfb25bd2c9314f85a2a1f8a33e60677ed2d45d));
        vk.gamma_abc[173] = Pairing.G1Point(uint256(0x182a96b7bb5786d8cdf87be46a322800b3e07dc1adaebd7877fdada3a7b9cdb1), uint256(0x277b56ad6284d5a6828247bbfbbff1bed4f0841ee616baed026b662cf4ea8a1d));
        vk.gamma_abc[174] = Pairing.G1Point(uint256(0x17f33bfe4ac3c71347b12d450ab273d5aeec0a0a09d307934c291a815d76b723), uint256(0x2646c9ad99ebd9ba4c6cf917fab4c94d83059033f1b303c8e5e2fcf58fb484f1));
        vk.gamma_abc[175] = Pairing.G1Point(uint256(0x0e08d54525d1ec9d126f6c1385458fe0d147a5a9214b6ff8d406160ae5a88990), uint256(0x17680d45ab0045db2d057e8655a49a3b791122622c55435d0bbb724220239218));
        vk.gamma_abc[176] = Pairing.G1Point(uint256(0x1049cc1e2ade1f638f1a814211b5c6ff10a83297eee40b57cbd25de80f76c998), uint256(0x2ddb587541d256c831da10ff401529f4a1eed88dcfecbef9f1a5e045839bfc6d));
        vk.gamma_abc[177] = Pairing.G1Point(uint256(0x2ebcbdd94dda29b3228250f81957f3639be2ddc4a95ce4f238667296509c85e2), uint256(0x0b1495870b175d0cf4e48c9a0c25158b34da1fe8dd4c1abe36dd07a017790401));
        vk.gamma_abc[178] = Pairing.G1Point(uint256(0x2bc756b95cf5ed4d594187d36f82e2dbda1d26f921d9cda4b7d25295f0abca77), uint256(0x00c40f401ea8f3ac4a6467a0a36c1ad876a7af987deafcc39334c1f1904c8644));
        vk.gamma_abc[179] = Pairing.G1Point(uint256(0x15cacf279c6f096670663495bd368d88cbdf9113c578a7f6d9aea49654d5aefe), uint256(0x0a7ae008b9e90973ca3656b6552ee4ee6bc1166d950f7e4fd8ee86f43ed04e1f));
        vk.gamma_abc[180] = Pairing.G1Point(uint256(0x0dfc0e767e1289787bf9ca5561fd4a7d137a62b9d1facd76395f7985cd89a626), uint256(0x2b8afa629f8bb3ad211fd97e511e2d977804412c54c4e374d8bb016a59b52958));
        vk.gamma_abc[181] = Pairing.G1Point(uint256(0x1ad0eb20723f3c466f6a0b6593164db81b69bd886b599ee0253b0a417e301fe0), uint256(0x078675194fdcfa01c965a4f9c79983d41955cafc37988aaf1af9af7bf381dc00));
        vk.gamma_abc[182] = Pairing.G1Point(uint256(0x25e1cbba2b42c4348e1c2a1206cbc01d0e07ef99f1f6e004ce060f33c0c44d83), uint256(0x2d871654b8f609f3d113538fe57b6e95e5096463d680e313e8e356effeded97e));
        vk.gamma_abc[183] = Pairing.G1Point(uint256(0x1433c036f7b41dc6e581c41d0441d8e542aad6470f0bcd4a42083b34aff2d924), uint256(0x1c2549d9c9dd892cd5586e6f504b3af436124edbd1b5b12550d53a49f710a69c));
        vk.gamma_abc[184] = Pairing.G1Point(uint256(0x10da8250964e31380691bfd5366518da8628d6e19e45d470b347ebcec8fe164b), uint256(0x2c4db85212393513f18b3c488790db050aa2edfcb15edda9a09cfacd3e2fe028));
        vk.gamma_abc[185] = Pairing.G1Point(uint256(0x14cedac2d8f40eb7d780057d8dc5a78a866ae22d2951833f671c6495c0eb7266), uint256(0x1a8aa257fa6bc1c4633bf6d4c6845379a6ed7e823556dda2fa2671543145cf40));
        vk.gamma_abc[186] = Pairing.G1Point(uint256(0x174639e7c308c92efea491d39c7b1e8af7f989d9f46271f133b86501e206280b), uint256(0x2406a81b4870f74c890b3ea95b166f801383c8719a2f4ac084b13f7ebc288e8e));
        vk.gamma_abc[187] = Pairing.G1Point(uint256(0x169533d14dbdeca3dfbbf32c99172f375e62be8e191613fb6241fd33570e1d9c), uint256(0x192aece680e55f51d634dc8f157d928d770d5186f877530f68858b9b3915d079));
        vk.gamma_abc[188] = Pairing.G1Point(uint256(0x2636bd7d1eb83cb192ec6df0b585980b294543b589d4a0505c6e31ebb603526a), uint256(0x1492e24f78dcecd8cbb98d38136ad8536594269c2ad53ab37bb37be14534cd92));
        vk.gamma_abc[189] = Pairing.G1Point(uint256(0x126b6f2dfb6ddc9cb10b2d4b895e219cb7813d7a58e656461d1ad47696706847), uint256(0x2a03a5561aa8eafa267d4d88caf0a541ee43e2bd28708713bc2dac3406122664));
        vk.gamma_abc[190] = Pairing.G1Point(uint256(0x232b64839330112a1fbecfd4cc288775c21db57f8cc076f623d2b7377bfa989b), uint256(0x151f4ff93ee0c6863606c31158f33e839bc82d74c5eff37a212c6d776972f30a));
        vk.gamma_abc[191] = Pairing.G1Point(uint256(0x216ba4792d46414c70a5281c0f579a175fa907c1749f2a67a0e86208dfbdf0cd), uint256(0x12289af86b1f1b3011b5909f8c6dadd9101f7abf6a2097ca2e9ac9efbd054dc9));
        vk.gamma_abc[192] = Pairing.G1Point(uint256(0x0e2d6ef9ba8e5db54ffa1e7e7903b95cb8ab0ef7fe75a7ad528dbe79b7761147), uint256(0x2319528021d8470d4bceaae36fd419b45aea6effd85761f616fad0738f78117c));
        vk.gamma_abc[193] = Pairing.G1Point(uint256(0x24b5dfadf26c89259b47accc0129c489a518ed9ad227281c6c2868f27722da50), uint256(0x02a217aeeb6e3a94ed123b71e86b286d051c83ca0716b889865e0618a4d6e250));
        vk.gamma_abc[194] = Pairing.G1Point(uint256(0x15e422e05671d33ef611f6b7927206c82fe8d573553bd63b64167500ea42f29d), uint256(0x1af49261467fe110ab59568d73a21a6a8dc30e6f4cbd4a3c3441782db580d291));
        vk.gamma_abc[195] = Pairing.G1Point(uint256(0x154aa37f8786335aae9e91a3d078cc12ef778b449cd100e856d84cb6a898f233), uint256(0x048bf6cf36c40a2622c7c5e7fd03ce3b19db892135d778fb1941830f023b9c9a));
        vk.gamma_abc[196] = Pairing.G1Point(uint256(0x164bdaac8d1de4834542b03e59ecff489de29d9856e05ed6a395eee8e8e3557a), uint256(0x265f7d17f04ddf0e54cb199511d2eb44cbfd2d16e3d96e714fbd444ed6467e77));
        vk.gamma_abc[197] = Pairing.G1Point(uint256(0x1c993c4b053412757cde0d9d8a08dcd665edd27b14c4277490fa8eea9dcc158c), uint256(0x02eee1fd10373660f8a4120075f73d02b71b7ff1a06ad6f0caee3751da26393b));
        vk.gamma_abc[198] = Pairing.G1Point(uint256(0x22bd2f54aa5186c600f745646fa8e4ad02ddd7300ed6f744b8b44c9f87dfdafc), uint256(0x0e7e229f08b7ea2304f804d8def5b03da43cd617c90d37e7eb3ded4fa3f21827));
        vk.gamma_abc[199] = Pairing.G1Point(uint256(0x068894f480e9a3990e81a98466e22143fddac5cd5d890cb138cc48b0fb635498), uint256(0x2ad66ccf8c9cd17f70533f816cf15e7a43c1dac44fa39338cebb90dc0d671fc2));
        vk.gamma_abc[200] = Pairing.G1Point(uint256(0x0e8af78d50a7a924686526410d4685db85bb769a05c9975951d19e5cb5d4d973), uint256(0x2472c1b7417674e392667bf07ad4d7bfae73869304d8122887b6034f43e29655));
        vk.gamma_abc[201] = Pairing.G1Point(uint256(0x0e7df18b6e90e16168e22eb29303240bf2e087390079f4e9c390724a97e67113), uint256(0x2762aa25330c78c7fe13888feb28f94d0d54ab6b9a810be13c5ebf96203503b2));
        vk.gamma_abc[202] = Pairing.G1Point(uint256(0x2ca6d188298aa44aaeeb7885a38281c490767582ec35819f27a895d64a0432f9), uint256(0x1cdcf28c66b1948a4f4f9a25553e8e9a8458c83519406a8d9f08582a4a855ba4));
        vk.gamma_abc[203] = Pairing.G1Point(uint256(0x0109011ae6c78e0446157493941f4ba24903670d15dc04b71a694bea2f20f458), uint256(0x1e7b04be475f6fbacc0aaa08c0a5c973a24c0e2752b280be9b9dde87d5b87e56));
        vk.gamma_abc[204] = Pairing.G1Point(uint256(0x08ac7d9b3dc4b973b42ce5d47a8adcbec742204af085385ef1c194cd07397ae8), uint256(0x1f3e2f44572b70ea59bcae23ce700b8810bc00ef7ed76397b8cced660b826de0));
        vk.gamma_abc[205] = Pairing.G1Point(uint256(0x0671b8765e99ce86636c50e003234aba5fbba2f1b483b4d94478fe905b7effd9), uint256(0x093a958a220a19319d406e8c95fd10b0b0af5859e4de952c87a9d36dfbb22fa9));
        vk.gamma_abc[206] = Pairing.G1Point(uint256(0x16b7de85eaeec2aabeacbc5e45d390d49488e5a882fbd0bb811506cae121f3b7), uint256(0x2125cbe0ee03967506cb82c52802882d13f230446ed2b54797d44280ac97dad0));
        vk.gamma_abc[207] = Pairing.G1Point(uint256(0x0ccfd48bb89827b9314513d8796f30239d963259f615bed729aed637402edf47), uint256(0x0b673f3fd2c108659afe17c8fbd17ed58217c8349b7025f5dcc12fd67653b5c9));
        vk.gamma_abc[208] = Pairing.G1Point(uint256(0x0187eec70ba177287487b39ebd3a3e3572d64e6cdf92687651ce28e4bb8aefe0), uint256(0x24d31d4d2e676ed08525143adf40a6d49ef52ac394bc29da83bc3decd58994b8));
        vk.gamma_abc[209] = Pairing.G1Point(uint256(0x1d44d70d51b13d8f6f27dcfd89be10f5e4f6e2165e56adec22b8e9aeff6a9a54), uint256(0x207dc307fb57646e0cf8a0064fdbc8117cedd0bf9b0153921adaad1f34ee9f9d));
        vk.gamma_abc[210] = Pairing.G1Point(uint256(0x0f808b7ba1b74d739317e500db3196cc9ea54f6c8731d9bd0cffff86785f76b6), uint256(0x06f592ef5900ccbe1c114854960220c435faff2ce52d388615c4b23b5da00aa9));
        vk.gamma_abc[211] = Pairing.G1Point(uint256(0x251302f6e7d8d5908e4c78b7a7ae9e120bf5ca706427ad574ee0bce40dfc4d8f), uint256(0x1f878d2dc654246dcb648a5c9402c1a01cb6b832d98c6b55d9d74a07d37e1379));
        vk.gamma_abc[212] = Pairing.G1Point(uint256(0x1ee7545c602664eb3c8ab1b48f699c5aa72614fed7d192340615ea78e77c838e), uint256(0x0922a8b6e351aafbada674eb101a4ec3c4225fec5c404f5e32178e81841f36f6));
        vk.gamma_abc[213] = Pairing.G1Point(uint256(0x292303f523bcc75bbff96806b3398a8ea04cea5821f61ea2e2b51c39772eb88e), uint256(0x1858c58b97bb7534a09f0359544f639eea5398b2814454814c64d03681f1f22d));
        vk.gamma_abc[214] = Pairing.G1Point(uint256(0x28c1d283ab589b2e881c9a83e928cbe69e62c86897dc52767168c1a6b4404868), uint256(0x1a70e8b1995436cd3a957a060011049ad1380c7a79e73aa67db0b3a17308b25a));
        vk.gamma_abc[215] = Pairing.G1Point(uint256(0x0aadc6a9dcc10a30102198c2b4a5c91c49405fefeb7d3406e9f2814370386fb9), uint256(0x223c225b38f8eca35e0f0b8f5e72db32bdc1bcd0cb7003d5d18edb557bf0aa85));
        vk.gamma_abc[216] = Pairing.G1Point(uint256(0x12706a65eaea7aa48f737f4f15c1815bd91ce1f47b940a4f90534f828d500419), uint256(0x0689f5c3f9c3770f9d405b3f9eef2025b4bf7d72d8ecaeee87a21327f817d6cc));
        vk.gamma_abc[217] = Pairing.G1Point(uint256(0x1cca6afeb3bb3ca8f7f10a3681548a401bd67b87a4b09b9aab56fdfa10add207), uint256(0x13063e9c74bd4bb1c5a0595eb7836afaa24b42097e1d4c8f710f40cc79618204));
        vk.gamma_abc[218] = Pairing.G1Point(uint256(0x087ce23e4fac8a51d42230cb734c92aa4e5b5d0c8cb2082f01c97056cfc3d7d8), uint256(0x21bfd7431c56964be9abb670efc8aa217cd55e6ae0b8b8fb5e1eb5bd0c1a73a9));
        vk.gamma_abc[219] = Pairing.G1Point(uint256(0x1fe4e19d26e19d6994ff492d43105ea0f2718972614fedf9c063756fb639be67), uint256(0x1947a34ff8816a2d3ab20eee267456949ca9fc1738e87df6a690a3e682624636));
        vk.gamma_abc[220] = Pairing.G1Point(uint256(0x10ccd8884f63df25981ee6888c7caac415e362aa24ac09294927a37e15e7430c), uint256(0x05364e261c5d6ebf0f7c00533c80db91383faf5867dd09608d01d19de6d0b134));
        vk.gamma_abc[221] = Pairing.G1Point(uint256(0x001faf8e042d0bc095f5c5ede927185443755d4280a5fb9e3fe79e08cc063099), uint256(0x15d8dce24498fca976331a98107aadac1e6ec1200c58f651f156bdf55207c87c));
        vk.gamma_abc[222] = Pairing.G1Point(uint256(0x01f3bda3881a0715cbd545534ec1aec695077ecbddbf156d60375f00c4da6e1d), uint256(0x218b0b273aad4d4baf945bcaf2a4e885fc37b17dde848215d2a6842430a18749));
        vk.gamma_abc[223] = Pairing.G1Point(uint256(0x15cbbb89151e7675cf0474c376ceb677cc23b1fafbf5c895e36c26e54569a8f6), uint256(0x21a8ef37f500abbf1bdea599a0f35ecc82d57bb53581b54971a28aa3e1f198f2));
        vk.gamma_abc[224] = Pairing.G1Point(uint256(0x0307ba0683e6683e6f3f7e29ca8fc06bccd02754c3b8d8848c1f6f514cb0e6f6), uint256(0x086436870b0f023ba4b745317b758c10754854986e4663ea11de5a25a7a52d03));
        vk.gamma_abc[225] = Pairing.G1Point(uint256(0x298802b691daf358730008e6c200fd57bbe58f06d3872a2b90ad32c67bdb771f), uint256(0x0e9ae870156d9d966737eb9859373fa1ed2b41f014dafa485b3daf22bdf17c96));
        vk.gamma_abc[226] = Pairing.G1Point(uint256(0x16acfacf2c56caac50d9fc0dbd6b0524ac0f5a4179ee37b60c5beeed1333663a), uint256(0x03faf33966a37e200218d6dae9b1e0f366e2c20e0612e54cf5af47cebd84408f));
        vk.gamma_abc[227] = Pairing.G1Point(uint256(0x22e5de7c3001511ccfc3cc1ab9ad388c77fb58279e104f24a59df5c6041c1bed), uint256(0x0b5a761a3a9eb2d9497e9fba6cad8432dad1f6d425af2fc75eeab6b27d426b96));
        vk.gamma_abc[228] = Pairing.G1Point(uint256(0x0ff77c2be2ab3b5dab57c65fd3ba0e0d399232f65e9f05659e6291ea11c1d23e), uint256(0x121493a8ce2d28245449a092aef23ac1db7dc785ad19a58ad94bd6bf820e5bc9));
        vk.gamma_abc[229] = Pairing.G1Point(uint256(0x1b608d28ef1ff769929b9c63dda916ea331677e320b9ee51f176073ce6791b1d), uint256(0x14c8597e40b3ffa1ba757bf0a41ff2dc5b44f2509915c6dfb716dff81b282f41));
        vk.gamma_abc[230] = Pairing.G1Point(uint256(0x0bbfa0bbf49c94b3056787762e02e3b92f17b8fa7766a9e84de4b7ed6bcc96bd), uint256(0x1e6a596d31b6ec328fc27dc8f09b55dc044786aaeb107c7932a8453197495cb4));
        vk.gamma_abc[231] = Pairing.G1Point(uint256(0x13e8fb35a6b32eb7de64862588d51f3b8c564574e741fd94be51f1eb3f5027c1), uint256(0x0748f1fb121509781f950c886a15ec94e77f66d74b01e2b10dcb26f9520de19b));
        vk.gamma_abc[232] = Pairing.G1Point(uint256(0x004352c91b7b22a52efe7335a2124e07cfcd16b2b5ebf9937cb8355ef3db2096), uint256(0x24c420df902f23b111c1c8cdba3eda4dfc075ba2b3e270ec2627bd4a420af3b7));
        vk.gamma_abc[233] = Pairing.G1Point(uint256(0x2ee29127594ce506b51547cae59eb74d5b86bc6abe0b7045814e8c800fcf5a83), uint256(0x239b1d7165a6e2289c320f7372be82fbe45d7a23dfbae91390005801dd22fc4b));
        vk.gamma_abc[234] = Pairing.G1Point(uint256(0x239462745d3ae49b5b0bef4b7e8fa7c2227c3088d30fd0d45a64671860037641), uint256(0x090b7687472a206baeefe49dae8612df5f64ef8e052b93e6c4454519569347a2));
        vk.gamma_abc[235] = Pairing.G1Point(uint256(0x28bb1c2f2c22c8c684df0204b1ea5db7046df5c84a27706ef1e67c99b32e19c2), uint256(0x14f7b7c8fd0c572b3b2f7502d90b49adfa9bb0e295f8c47303de7de4373d45ea));
        vk.gamma_abc[236] = Pairing.G1Point(uint256(0x06aabd24b0557631c1f40174b508ee544cac4028a02adc9933d72891a7dbd1e7), uint256(0x0fb3f05c7cfd022d44d52fabc4a0f23925a1d14237cf7143c14c90b0242926e7));
        vk.gamma_abc[237] = Pairing.G1Point(uint256(0x2bd539a9f31dc49dc258fcae5c3c9e2bd49d2273f0dbb69b648d931c9dbb7fa8), uint256(0x1404ec4218d30502d7dfe6f5375d98780aa9465f2e07d1ccc47196182051e03b));
        vk.gamma_abc[238] = Pairing.G1Point(uint256(0x1221c20a2eccf3f77abdc1fe070adeb585350b3eadcc457f6ad665108c759c80), uint256(0x281dd6897060db5af6f51c58d3ab3fcdd7795d6840ef1d41839feadf9833733c));
        vk.gamma_abc[239] = Pairing.G1Point(uint256(0x24ea93ef1ebfe76d57f4ac04b9548610f08d7515c3977c297a55d7e3c2177f75), uint256(0x28110e8f77ed3a607035097693fc6b6f2113167541471d9915d8d3e671bd4ee8));
        vk.gamma_abc[240] = Pairing.G1Point(uint256(0x1560417f99170cbdbe8060110f30e15120cf9bc214b81cb9dab5d7139316721a), uint256(0x1da9062244ebd1d12ba57357fac7a8f4cd05f4cff46d0bc7df6fabb637f228d1));
        vk.gamma_abc[241] = Pairing.G1Point(uint256(0x11fe980d2098528d266445919a423e47918ddb52c1586238783a5a9b04bcc86d), uint256(0x0e2273c71446fe932143489aacc8719e8d9eed72479e590f4c7af45ca285db9d));
        vk.gamma_abc[242] = Pairing.G1Point(uint256(0x11dca579056be0ae0b3743fd11c75fb30eda40705946543575fcecfb10fcd02c), uint256(0x26351dd88a65d24986642317604190da8a8b17288f77cd2dee9526be7f8bdfff));
        vk.gamma_abc[243] = Pairing.G1Point(uint256(0x0b6d5b7ad20409f193c8616ff1b47f8924d56fea8e427d613d2eefbadec357ea), uint256(0x23dfa047fdb0c0e5ec659f1f18e13a702a9fc1c639dfa64f162ebbc73da9e66c));
        vk.gamma_abc[244] = Pairing.G1Point(uint256(0x139d051496e2f666310fc037209405b22376ee765651b97d032428a82376764f), uint256(0x14dd89e59a31daab9fb858dca09032444bcc42040112796a8a957fd11afc8a5e));
        vk.gamma_abc[245] = Pairing.G1Point(uint256(0x11bd9d2d8a92eee358bc1c2534bf685faeb8c48ec6e052e67293dea44d8cc4fe), uint256(0x16904d9a21b49925bc5c9c09e08d943eb1e6fa5389b4a786bcf7539bc8e1dcce));
        vk.gamma_abc[246] = Pairing.G1Point(uint256(0x0fe294980964dd0697f94fe5ea0c5133c7b4b30f337a92a7b5a232d0d09734a9), uint256(0x18b4cbfd106c5c0e4ef8e865b9ce50caeaa0bdfc11b62b0c404eb190422d6aaf));
        vk.gamma_abc[247] = Pairing.G1Point(uint256(0x155ab40ac4f2efdaf21767e0288e140b97798a43aa0e416fc95924e17a3ab443), uint256(0x17a237459c1f24d42e8c0fa3aa832d4a10f647b1230a27e54f9259b241d89756));
        vk.gamma_abc[248] = Pairing.G1Point(uint256(0x0a0b285327e9bafe13a022bd713b22879e63041c633e272f754d74d3b262a9cb), uint256(0x2cc767159383083f94349117089c8663ec02289767791482f9e64aa45a6fe55d));
        vk.gamma_abc[249] = Pairing.G1Point(uint256(0x13b60fbdaaa7a3dfc1321ecb5e0dfb6bab3988cd537011f79a116bb076656282), uint256(0x0303089913b29e634813167743f66cc9ee865dad602f39df71b239edd1b93ac7));
        vk.gamma_abc[250] = Pairing.G1Point(uint256(0x2cf1b5448b375387eb037c40543c659a6471027f81f7084fa521c2824b99aeec), uint256(0x259a003afcb3a6d2825c5645789b6bf1d50be1a4d54e7e2ff8d81618422d353e));
        vk.gamma_abc[251] = Pairing.G1Point(uint256(0x054e9103735820ae2b9b03176dbddf16b76bbc2a82315bafa069c2ba0a3e07fa), uint256(0x1158c32d947caf51514822b2e299bec5695f5b52f7929e5163109e6fc7d607ac));
        vk.gamma_abc[252] = Pairing.G1Point(uint256(0x0534dca6236ed38b144a55a6b2104c65190437b3695e38a6abb48de96019115c), uint256(0x1cb2dded4f975c6043aa853576b78c58806d9d0f5cfc9cee42bee91c0d8c9e6c));
        vk.gamma_abc[253] = Pairing.G1Point(uint256(0x296dece378ba2842518083d7370f9514402673e62bc77047e7128fd42f7615b3), uint256(0x288023b98ff61a113b468088951eae94a9c51fbab9bf9de213b743d3ea030491));
        vk.gamma_abc[254] = Pairing.G1Point(uint256(0x175a068ba043c37908694a29bd9870592e6cec3f00fdcd16fe4a9c95141c1b95), uint256(0x1a88dbc183b4f3a98b168bdb0e33c805b615a223756818022710d82b065e52c1));
        vk.gamma_abc[255] = Pairing.G1Point(uint256(0x2a57f342cc93f0aa0fd03a4f548ca5d482228831c1ac57bc282fd71f8af7407e), uint256(0x21bdbeed219fbbfcc5302d50c0a545a8c40f656153c16d3c33f04a7504cfe6e3));
        vk.gamma_abc[256] = Pairing.G1Point(uint256(0x2a2a99fbe738ad58f8535440e6cc11ca5409c8e51f06bd4eb887111d79f76450), uint256(0x125e00b793329589e54f9a19ec78b09fa1a79163cca4cf1ed2d3941cc7362b6b));
        vk.gamma_abc[257] = Pairing.G1Point(uint256(0x09a840c61a5f03f16bf6e8e1b0593d0302ab89a4f39fd2e5c564fe4f46ae17d9), uint256(0x01bbabc219ece91419e5e88176d9768f28ff1a845563ea3604f7bc96873b9375));
        vk.gamma_abc[258] = Pairing.G1Point(uint256(0x2a0042cb5f989a85daacb4a164d467a8d2404a72b7647b8c73ec15137a2bd336), uint256(0x1298ea1017eb576443821354d370d4a2b9ab87667d4a2766305b3accaee272dc));
        vk.gamma_abc[259] = Pairing.G1Point(uint256(0x166250dd8106af1d85937773c22a2a845cad1f072b20d1f2d7d0ed8eb0f26e17), uint256(0x28f36cdf2b28a534c0b941d92221dbab6b847c1fd76f33ff638dbb78ba0711de));
        vk.gamma_abc[260] = Pairing.G1Point(uint256(0x1e2438f43de7bdbc519ed891d159ad006355dee06f2c37914a433f28cd808db2), uint256(0x0b0f82c8ca47c59e639d21de3694589c2a29711004e6ce5e227ae981574cefc3));
        vk.gamma_abc[261] = Pairing.G1Point(uint256(0x214bc5750a668c866b264cd221aa79436d431c46d6272a188df268b08239dc34), uint256(0x2b2f5c9c65d8aa7dd57feff3421b7eb7a628a7d7a097670037159efb3aa5fb72));
        vk.gamma_abc[262] = Pairing.G1Point(uint256(0x013681f5ec47032dba731c769d67bc372b7d20aaf23a57ce94e35d2f5c9e447d), uint256(0x04a809ae0af42ba653cf50ba24878813ebc038fe6be8a4856a466792efed5ce9));
        vk.gamma_abc[263] = Pairing.G1Point(uint256(0x248109f30d4db5e94931c94879d4fb0f6d8163713f18633759b5666da0b745ff), uint256(0x0c253ab4d1ee4cb56d9cce817782aa5873a03038c41fe3725eb6bab99af6eaf2));
        vk.gamma_abc[264] = Pairing.G1Point(uint256(0x258f4919611930bdf5de65c358c1ebedff5d2e424370696533a1090e5402df83), uint256(0x208ab40b22a7728c79a556cc390f4d650713f06eb02a192d84d297754c399ec1));
        vk.gamma_abc[265] = Pairing.G1Point(uint256(0x27a59e7068b1d222b4b0ef54943fa41be47f175ae02c2323bd5ab55b3ff20a75), uint256(0x2eeb7aff5b4534eb0a077cb60fa29811f3d45332ab1acc7ec634ff234ddd018e));
        vk.gamma_abc[266] = Pairing.G1Point(uint256(0x20cb34250936495258b5f499d72d6333fc4058389ae4a82573e7c1946d855f55), uint256(0x1a7d1d1d5e9c5199baecc403550b17193003bad8901435e8157eb8121d70dbb3));
        vk.gamma_abc[267] = Pairing.G1Point(uint256(0x05c3da150c6f908c3f1bd3a47fd76b2e9aca84cacfebf48417f03b9c75009b97), uint256(0x05c422ee44a906d174e20e5f59e8762723e4dcee1e33c7caeb3049fdb97ff163));
        vk.gamma_abc[268] = Pairing.G1Point(uint256(0x08323f9e886b416d516cddecd17175222994334fdf56f80d5306eab8e0e142c1), uint256(0x17ef48dfea0b09d93a067699f2ab5571b5fa84c9623b4574ef78c8a0c5e7532e));
        vk.gamma_abc[269] = Pairing.G1Point(uint256(0x29debca88cb9973aabf285952a5bfdd926d2791632997d05459d4e657ec70a6a), uint256(0x231957c8e0e80fabbdfcbdf1ff55af5f6d31029e16095b4b6c43085d55eb71e8));
        vk.gamma_abc[270] = Pairing.G1Point(uint256(0x11c7e0bebf5b7e21c42025fb1b3c173d0bce2603398e14e87440abb7f6b01fa2), uint256(0x07d8cb38dde724bb12b69b99e357f0fa3ae16a1e4bfa540e9fefc2b13d721113));
        vk.gamma_abc[271] = Pairing.G1Point(uint256(0x091f12df537f607218728688b5f29fa7ac437cf8b38a58a9f93707220de621dd), uint256(0x117e4d14bce554c30fff06e0cf4d8e21a9c9e7769386a8214e68f09b2f59d4c1));
        vk.gamma_abc[272] = Pairing.G1Point(uint256(0x28b7fde8e3ee94fca0144cb16ad5420c0147cfadfcef661377849e476c21c5bc), uint256(0x1bd8c21df51d0295ae6bdfea6cc17f3fc881ae0583e0f2d640521d16cd7ae638));
        vk.gamma_abc[273] = Pairing.G1Point(uint256(0x0711b4fa70ffe438e656f004ab526b0a8c00eb3d83483374c5685e7a2a920254), uint256(0x1f4d49a4433c7dfbd4aab7c6a4f80afea02ca129361ea8d210138e91e8615688));
        vk.gamma_abc[274] = Pairing.G1Point(uint256(0x0ea19744710e893699f78e48f173cf44faf529c90432301c652a4c74dc1347e1), uint256(0x21908b65a037668e4034e9acf5a255fc0962dc3c0f23502774725c0b585fc03f));
        vk.gamma_abc[275] = Pairing.G1Point(uint256(0x2942b124348db9a256490251303a7b54adb70907e7680b6c04743eca7a1802ad), uint256(0x2a6ff87a234cb1d27fb8dd5627dbfaef7da71c69752414b2ff7d05eef2a8ac60));
        vk.gamma_abc[276] = Pairing.G1Point(uint256(0x0c76e035436bcc1660f3ecb96546c8b7376ef1b191e03ef3d312e286267228f5), uint256(0x1a6a9d6e8f51f4fc2fc6133a5f1b468f6889e0dc3f46423a99163da369c89c57));
        vk.gamma_abc[277] = Pairing.G1Point(uint256(0x189bb8672c3e1406ae3aa8c5c6d2cdcdc6e1ea362a6c49536a7e6248a31a2c49), uint256(0x1dbaf6e6a325441615c1c1ad828ad8551d0fd147cdc6d1733ba977efc08b3042));
        vk.gamma_abc[278] = Pairing.G1Point(uint256(0x1767ea4ae273aca5b807dba9d308b5a473b6cfb7be565ec5d0a557a7663e77b0), uint256(0x17735544cfa170c416e0db68914ac50f828f9d5537450a7e5c3d001cc1421b20));
        vk.gamma_abc[279] = Pairing.G1Point(uint256(0x0b8529d8c766536adcbf5f13570e8d0744d6184b9922611d3c5111ee2f7cee04), uint256(0x16e10ad3630d822bd8b334dc629614458bb73c7903a875add67a328f618cc234));
        vk.gamma_abc[280] = Pairing.G1Point(uint256(0x0a720173a25c32bbe4bff630241491cdb93b30ac550c7d35c0f8166fb6ec84f1), uint256(0x2b68c17cf12c17e1bf5ecdaba5a1d7d5809fe9324ca4c789f5f2255f129e3a30));
        vk.gamma_abc[281] = Pairing.G1Point(uint256(0x27fb6c146695d5d18402fdc09a57f3ced36dbfb574cf17758df6f2a8efc08846), uint256(0x105d2036535d35728724cf763d2db273fe9bf63478762c4066d53a520279ac83));
        vk.gamma_abc[282] = Pairing.G1Point(uint256(0x25cbe76598f2f6465421fa625ebe03e409b5edc99e09df53e4783eca36fa5422), uint256(0x16714e6f0606401b24fea285b552640c418d011d3e8d4dc55f0d4c73598de783));
        vk.gamma_abc[283] = Pairing.G1Point(uint256(0x097860d8b482b0efcf0bec569caae033c478c42df529f95f86b3124569c66e7d), uint256(0x052084f79563c3eb581fcdbf78b2bcdad558567475ff2a937d0673d8d35bb883));
        vk.gamma_abc[284] = Pairing.G1Point(uint256(0x1295814ee426af63331cc674e04cee18b9defec6e045f7f37ac27c74630840b1), uint256(0x2301807cb007dfdc889daf034e7672e51c62f84e455b8db1ddcbebd3ef41c3a8));
        vk.gamma_abc[285] = Pairing.G1Point(uint256(0x1589c5bb39302725f08d263b5399ed087eea82f30a6f9541afecd9d361a774a3), uint256(0x17bb11b927e2aedc6444976309e198aa6abe296e9303118a4ae25bb765888b2a));
        vk.gamma_abc[286] = Pairing.G1Point(uint256(0x0d18a6dd570a9a333b71bb4f7dc47eb5fb05c07d52ff927f0ec2fa6b4400ee05), uint256(0x2f6b31bdd965af8e286f985ad3fb3a6b5cb3eda13af5ac17f5f333dc1358f035));
        vk.gamma_abc[287] = Pairing.G1Point(uint256(0x0fb496f744f4bf5d08b5358ba06df393e6da1030087c58db4857a2fca1394187), uint256(0x2d1c64541fd58184d8f59843d947b5729af708c11f0e32a92f32f530c70b4a27));
        vk.gamma_abc[288] = Pairing.G1Point(uint256(0x05f84bc32561c3ca30be3e1c71c09d5b98fe994a5b4aea1e66de4ff37d965211), uint256(0x2f7f7bc13e0ab5de9051edd50182b15b73eddaeb414acb9e16815ae27882feb3));
        vk.gamma_abc[289] = Pairing.G1Point(uint256(0x2ea3863b432147a06b6adce72c1c34094009697cffbc0fdb71f590457760f85e), uint256(0x20720b8234f3981b883cdf64f949d319f720881c5644ff23310a6e98e4551fc7));
        vk.gamma_abc[290] = Pairing.G1Point(uint256(0x107ef4580ba200c98a1431c352eb0afaeba3f2134aa049364cefc934b887c038), uint256(0x0511fbbf50f9e33573d2ca03e42e40d1746bf2b3f7ae4aedd74ba0e110ee8ca9));
        vk.gamma_abc[291] = Pairing.G1Point(uint256(0x176b96ef3bf68f4328407ab4d8baabd867349e5f206428dd7cffbd940d8b6439), uint256(0x03eb84cb568cbaf7ab70b728da1a2acb356fad19fed05f4191df3d6a100c7c09));
        vk.gamma_abc[292] = Pairing.G1Point(uint256(0x2f3fcbf3bbd9dee3a92adbba1ecbdf6c04487511252e27c1070fadc18ff923a2), uint256(0x146b16cd2a5a32037727d0d77faccf2bc42f96c2d8f900575f62008b32bda76d));
        vk.gamma_abc[293] = Pairing.G1Point(uint256(0x02d3671b7785e0d943417247c8e8deb00b110c15d18772cbcb521a0657633409), uint256(0x25d2963e679453d08ed51ed69f034abcc299314afdf3fb00d4262971ccee7509));
        vk.gamma_abc[294] = Pairing.G1Point(uint256(0x0eaf9df9ed93bec25258ebdb6d244f5bb814c224146fa0dd665fbbb3d8de6add), uint256(0x0c748132f9dce568718988be3e17b8c9c475ddfc907bf5b01a02b19efacceab2));
        vk.gamma_abc[295] = Pairing.G1Point(uint256(0x1cba4ef023bb69809e440290f3c14c6fdf9730cc5c787ce85d13656fb5b62472), uint256(0x2e644c2ed37f0e44e78e6e0aa89745dd1920d7871d4d626e113ab84bd001d7b3));
        vk.gamma_abc[296] = Pairing.G1Point(uint256(0x1473808668097f2516048e4e8dabeb01aadbc97e519cf6fb0939c2f814349539), uint256(0x1b408fcf6ca4d6188149a5345ac4453a71bab069b7f6d9c0b0b0b91f9988c120));
        vk.gamma_abc[297] = Pairing.G1Point(uint256(0x05e8e657a5f67418571ee823019421417b3d9d55fcd4d0f267c52db5deb8601d), uint256(0x12efd57c96d6b689f4f247fe223e913bfc5a20c682de36c29140df33f860433d));
        vk.gamma_abc[298] = Pairing.G1Point(uint256(0x13b5f327d2d34dda8a9811ff9b3f710b7ab819bae98de518a45ef109d05e948d), uint256(0x2f5230b05011cad0d2f9088c1b4eb3f6d63391674dc319c285d4095183eb8d8f));
        vk.gamma_abc[299] = Pairing.G1Point(uint256(0x073a0b201cf23d1764534dcb72180559fe57a574a4cc947059506a9200926296), uint256(0x1b3b93004c82aaf6cd299ef72d726edc4a49e4f6f946be9388154f4d8055bd60));
        vk.gamma_abc[300] = Pairing.G1Point(uint256(0x21182ca52a387912d10fcd0fff7068b7bd1b090b8436c79597b244df563f8a7d), uint256(0x07803e332c22005543b973038a1474e5a0de7f7c7f201c68ab3f497449a7a385));
        vk.gamma_abc[301] = Pairing.G1Point(uint256(0x1d1cdcf59f435c89ecff8a3f69520d65bfeb776bde65da51f9a8efeda7177cc6), uint256(0x1455939e841518e5c07ba3afb7731fb02e6acf590fba5a57dc640c189e60ef7b));
        vk.gamma_abc[302] = Pairing.G1Point(uint256(0x066f7dad103c6e9c05530b21ef10ea0b8f82cbab0957cdf2fc6d2fc6a5ef16a9), uint256(0x13813ebbed770fa9a67aaf2fd15f69fbaf0fb01540831095786980b2b55a5d54));
        vk.gamma_abc[303] = Pairing.G1Point(uint256(0x13d08bed931d22afbd2704ba3ce5b902baa00ef477dd5b3a97cc512e01d73f4f), uint256(0x046398bcdd269424ab38632531cfe191cef43218c206836101ed20a94c748a46));
        vk.gamma_abc[304] = Pairing.G1Point(uint256(0x0ca3fca727c6fd514d4f4d8aa1f60e965db0eb1c2b01da168f84a0ff1e20cbc5), uint256(0x182a807e46e994caa91028fb4c5d976e27cd99e1ecef52661f2d183976226af0));
        vk.gamma_abc[305] = Pairing.G1Point(uint256(0x20b0995edfaddaf296516410a61d289109113a72bb7166f30304f703110342ff), uint256(0x1ea0fd9c46cde9a897656cc34aeb7785cbf925ac54d2b759d233c5ec20532dae));
        vk.gamma_abc[306] = Pairing.G1Point(uint256(0x12b16c44835287bdca723bc5eee2433afdca4ce73a3b731b0086da032a9dfee7), uint256(0x28413153dab936208703ad65fea98c6eca77e1abab50d85aa5331fed9f8e206c));
        vk.gamma_abc[307] = Pairing.G1Point(uint256(0x1fcefd3af42fceb721cbe9d9b4382fca0a6786c8fd327d72a39bb2d89189c240), uint256(0x19d4e984b5e91e42fde2d7cce73289f71ef5e64491e7c78d380ddede9490b733));
        vk.gamma_abc[308] = Pairing.G1Point(uint256(0x005f829e70f35719eacbed3aae2e799804c2477564154848fc60362444d0f673), uint256(0x2fb2dc005920bf0f28ee3c13f6f0a7803bb9604ad6c51cf40c95971c3671d339));
        vk.gamma_abc[309] = Pairing.G1Point(uint256(0x2f7e0d4c97f1b8d14650cfa88c0528638b4410e8e650eadc1a07675fdd0bd42e), uint256(0x179884435dc20408e968d44735698198c64fcd840cc8e8f14625abfb4c9a7190));
        vk.gamma_abc[310] = Pairing.G1Point(uint256(0x0847e03c2a81040b694e7cf3ca4f632282cce5d24d5e53e0c174e26a444c05df), uint256(0x06f7260b80bf1cb9a6ff9cfd9ba6749e822ceb4f087a445c410d7c320eda2d6c));
        vk.gamma_abc[311] = Pairing.G1Point(uint256(0x0e65adfe8bc7d6bde990685ebdebd2af89cfd43162cff821bbe880e985ed801a), uint256(0x09ac661943694a34dabb232d7bb8bf265d8e91165a14d04b01df0cff94b1f450));
        vk.gamma_abc[312] = Pairing.G1Point(uint256(0x116495e790ab3fc7f0cd0190724356480300c630c2fdfcf8c396d542565a02a0), uint256(0x2365f4c9f7c5f4ee9511842c014e50817d1d2c4fc487915a798b93b94ca3e2fe));
        vk.gamma_abc[313] = Pairing.G1Point(uint256(0x26eb5b1edc2f26c4ac435ed4278423121619115b38edba55773c7f754b1870d6), uint256(0x1c875b144ff5de2916aa6ba61cf8e4cde20c35c69cbc2ebf24ce9c0ef2f7a127));
        vk.gamma_abc[314] = Pairing.G1Point(uint256(0x065e3b6ee8e1857a4f8e69ce3d26915805c7b9be6c64d0f8b1872862c62ad199), uint256(0x1c17f2c32b96bfbb990710b9977d011ef64ed11078606110c12d7b582b5f4a7f));
        vk.gamma_abc[315] = Pairing.G1Point(uint256(0x283ad6d5d2e2120bcb7276d86adc1b7bb5dbe9b97d533a25b318b7a41855409c), uint256(0x23e52453ef03499bf2d03dcfe05fe56e3286a53feb44cc138eee18bf5274a62b));
        vk.gamma_abc[316] = Pairing.G1Point(uint256(0x22739128ea75ebdbc8002aafa6b5de4c0c79fcf5d7b864a93e79f514ba7a6904), uint256(0x0dfea102b53b9556b36d7eeee1dbda08e2e156a13b171bdcc2fb09fdf2bdc4bd));
        vk.gamma_abc[317] = Pairing.G1Point(uint256(0x20937351e52c9821cf03cd21c4820cf79f29a45ce3ab0151cb90d8bc8ea30efe), uint256(0x1f283b47c7e67ee0f8920280abdb1a3cd70d8abb1061d82f8f569f4adc3bfc2a));
        vk.gamma_abc[318] = Pairing.G1Point(uint256(0x14ad372092adcca73e9f0c6919b2eea278aed96286af9db06cd7bf78c15f1e3d), uint256(0x11b3539670e0e9506c97e3c5a82f2426d31094474073eabd30147f648910d658));
        vk.gamma_abc[319] = Pairing.G1Point(uint256(0x0db660dd3e0dc91b081be235814d5d86d038a80d84c222288634d9a72a578fd0), uint256(0x1dbd542b6cbb82e52ae716f7e38b029d29ea97ab5eebd3464e72a5887199f8c8));
        vk.gamma_abc[320] = Pairing.G1Point(uint256(0x1ff95ba5b3385a487bb899ea7583510e7765c361e4233fa3c2b8f536f419a9a1), uint256(0x1376c320ef1e256f45822f474002294ddf1cebac1122f035a48c4a71f573f266));
        vk.gamma_abc[321] = Pairing.G1Point(uint256(0x1d1b48e2be59ed3a4f907683ae71e65546cd80c23121558425897e9ebc4dbec3), uint256(0x15fb0cc45ada927891fc585dd5d00cf20bb5b399e939b407a61ff0346041b251));
        vk.gamma_abc[322] = Pairing.G1Point(uint256(0x23ea946134ec362e5126b99c57fa83f763db1cf0d7ee4aeb4ba84db5fb1ab9d2), uint256(0x16fcf8dfb05e9488be6fa5eb626103fe32dc23b954dd54e6642b9d61bd8502cc));
        vk.gamma_abc[323] = Pairing.G1Point(uint256(0x1e96fad7cf6f8fa4a3b8d69377b1a5edce33de5defc77fa11830490c433c786c), uint256(0x1ae9aac24d70ed7c2cbdad6b092c68f3b6a7bb51e4d8ba8f2bdc7b210e47509f));
        vk.gamma_abc[324] = Pairing.G1Point(uint256(0x2680cede17245ae342d74ded41eb34a5e59a30f403f1cd7fcc41a9ecaec4413e), uint256(0x25530888731662907a06ef0ecd8f99e334ee02a5502714c5759078f51648a0d3));
        vk.gamma_abc[325] = Pairing.G1Point(uint256(0x1af6f33428cbe4d001911623071a2f95f3df739259d1226694bb9f2504ed7271), uint256(0x2417834bdc40040a0fab7483ace962e5053392fb19600f601dc8839c80a0879c));
        vk.gamma_abc[326] = Pairing.G1Point(uint256(0x1a750f0b5332c1fd002d0fbcca4a76c0b9605cb452a1e99d887f2ae6c3ec2b1e), uint256(0x0f279557e5f0f0bf37b5815be7e01fee4239f0df65399e7af00022f6c0e0ccbe));
        vk.gamma_abc[327] = Pairing.G1Point(uint256(0x203010f0a5c44917c7f092fd7ba31bc0c5cc68ecd01cd27fe58bb8ae7d7e2eca), uint256(0x21739ef30fafc75ab71a2c2186218df15e5cc051216747ec6e7d1a94e901a44d));
        vk.gamma_abc[328] = Pairing.G1Point(uint256(0x2f3377d5e4cf072249994c0feff4bc337d84d0772a3e94fe7f4d9549870aacbb), uint256(0x0a8930bbb5be0dd4703f7768101e02c887b9da30d948771664848ade7c7f89ef));
        vk.gamma_abc[329] = Pairing.G1Point(uint256(0x2bf3376c13da0ef16c513189e00c588d1f75c920e8b61f2406932ff474bcbb6f), uint256(0x01cf04d517f8f6b5451b8e9522200847c6fd71ee7a8e06d37ee67d2a20a96c59));
        vk.gamma_abc[330] = Pairing.G1Point(uint256(0x1e6aabc8810f0e5f19c9caa87fc2455d014324692132304163d1e5b935a26cdd), uint256(0x00a33bbe3c77c9174618eb78798466bb22d845e36246037527a99af7cc9c653b));
        vk.gamma_abc[331] = Pairing.G1Point(uint256(0x21fd2e76ff60bb293a39dac3c94922e4d69dfdd0e2eaf3cf1e1f1f68bc71d1e0), uint256(0x2cbabc20b5c515a67025aa9ed0886e7d3527c4f0e23ee69965cc3bbd9c1696c5));
        vk.gamma_abc[332] = Pairing.G1Point(uint256(0x20ba50b0d81884a30bbcadb8cb2d0b35e8e9a82c248639bd45766d6909611b6a), uint256(0x2cf336b2bbc438d5e61a9f3506cae5e1daba2aabda6eb117a6781fd68032ad6f));
        vk.gamma_abc[333] = Pairing.G1Point(uint256(0x05220d04a4278183ac427655afd32403525a28d944f17ae3b762cd257f4956cd), uint256(0x2643457a24c26f35730bd8c18d2e38c83d3c672bf2de5bd0caacefa979d9e448));
        vk.gamma_abc[334] = Pairing.G1Point(uint256(0x0ff7d9803685e70b9ef723da9412eb1c06858fea843c122cf1c6ccfc84e0a469), uint256(0x058f7c6ef2a01798aca979a7e61c4a7860f2a0e9f7934acd124c9a0d13f4543f));
        vk.gamma_abc[335] = Pairing.G1Point(uint256(0x11fd62fb21bc4dd7fbaa226074f52c67545ff57a0d43e719ca3380772bddacb5), uint256(0x0b28421178aabc618dd9246a0a9c2c1681961543f6acaf65ca981cf8aae55bf5));
        vk.gamma_abc[336] = Pairing.G1Point(uint256(0x1731fb0880a880c1a2bf6d1144244a1db11b03eb50fb9768e0ff131125ba37a8), uint256(0x0f1eb258a1ddfbd4adc2c18de211aa7161d1b776342e63232801b02fd3c342ef));
        vk.gamma_abc[337] = Pairing.G1Point(uint256(0x13ed6fb335efd5bf497eeeb601b830435452dc01bde0daabe6397a86d9ec8e4d), uint256(0x2674a6a6b92d135aef04f06cd6b96e74dd9a54f62c7a529993e7a051d416e302));
        vk.gamma_abc[338] = Pairing.G1Point(uint256(0x112503a91a4df83e5ddb6100329f23e1f0bc8d5a4724d65b7d05a90085739de0), uint256(0x0dd354cd9bffc9606d4b6c34797e76135e64be63b3679bb52601e41f4226e3ab));
        vk.gamma_abc[339] = Pairing.G1Point(uint256(0x26f69cc04ccb62d832b041b6b281f5aacc624fdcb0ec406cf2cf453748d134cb), uint256(0x20b537a4060d326673fb0dfe7a056daf29989f1de04dc39137997c53329e9862));
        vk.gamma_abc[340] = Pairing.G1Point(uint256(0x1e9057cc46ee3acc063733325e2ef8357f2333d2edcdb843911edb9c46e32787), uint256(0x2cc4d1544ee6e5524826a4914c4905cf7825590294fb1dc9a8809103ae0028f4));
        vk.gamma_abc[341] = Pairing.G1Point(uint256(0x0422724234654f294573a63ef179a715d0946d583bce04a6d108a5982d481f1c), uint256(0x1ff31415cdd5117fe51d0efdb7f241acffb5f87fb7feb4307710be2c02277434));
        vk.gamma_abc[342] = Pairing.G1Point(uint256(0x0e899765e055b52c19e8533b55aaf7da393bde12019ae8481eaa9eab73fd156f), uint256(0x1a1639d9211e7b2ef96de1e4e3d7fb6624cfd12a8b4405170eb2191acf01679e));
        vk.gamma_abc[343] = Pairing.G1Point(uint256(0x234a6974a62a96d543f83749f0b36231bb401cc701f7ce5988f028d92c2077a2), uint256(0x2ed4c887ed1543923188742a101021f2895977d8297e336db446130d9df605e1));
        vk.gamma_abc[344] = Pairing.G1Point(uint256(0x22ad21fcf309490252b5780aad8bb6383710e2484fc7c96fb4ed839179b16fe4), uint256(0x2413e037b55730b87cf5f66005351e299ae42f38a14de3d5706aeec824325a16));
        vk.gamma_abc[345] = Pairing.G1Point(uint256(0x0f76d4497e8c84ab00fb628324659cd7e7e370b0db94edce0fe3ee989b643b24), uint256(0x27c2c4951cba1a8832ef562cc1454f9d7db80dee8f21d5e673ce08a3e0da3287));
        vk.gamma_abc[346] = Pairing.G1Point(uint256(0x108698fe570c48d26e2a834f9a7f403452aea8421396c01737610b2b823aac22), uint256(0x024fac6a52a826742370dd9dfdabb0c96cac7c9b33d75fe258247e4422c79aeb));
        vk.gamma_abc[347] = Pairing.G1Point(uint256(0x24d9667a808d01cffbede5044a750b57f1871452b8f47cfedba52d13d5db4aea), uint256(0x0bc8e161abe41be1652a7abc8561002ebeaa044704676ab73286002cde154362));
        vk.gamma_abc[348] = Pairing.G1Point(uint256(0x23282631d46c898d25609d19a9c8c570808a88c4077dfe0e1e8e66538443bd86), uint256(0x0368ff6bb8e7e6512b41fa445dd0101d12726fd4099702d13453f2b54355d57d));
        vk.gamma_abc[349] = Pairing.G1Point(uint256(0x1866ed000e18e537c6c87fbaaa47d32836963274c9552d98a55158a1acae7fba), uint256(0x1242453d02e20e9f2028c60078c8e952ba8ddd5fc9eb8a0707ee8fc4275b895f));
        vk.gamma_abc[350] = Pairing.G1Point(uint256(0x1f06e4672c996b0eef70e0aac986b33a14427fceeac52e22f89229030b1525ef), uint256(0x07df514236890522ba4a87a1b54c39a904c2b720c956738ba5475f9743460c2e));
        vk.gamma_abc[351] = Pairing.G1Point(uint256(0x06a5de775a3d263af67178997c02161e134e9979fa7951aa8d31e35623a34826), uint256(0x2993ec6ee9b9697f196baaa432dd8782b8a1cc23ebcbedcd1ad1213ff6f35184));
        vk.gamma_abc[352] = Pairing.G1Point(uint256(0x05d92682f73bfd49e2bf7c1e7dd4367d3d788a36af625a4c4450f49d2cfa4b04), uint256(0x0ac0df500ef36e0f8985f894c4f595d7d10089db2aaa44d7931e61d471cb1d38));
        vk.gamma_abc[353] = Pairing.G1Point(uint256(0x1b2ebd1f3f24d57e4cc6e3a2b0958f75b9cd9c12f3b5b29c083310cf67540879), uint256(0x24973d432e024d4b490c4af34f08d31029009048a94258f6c8551876a202226e));
        vk.gamma_abc[354] = Pairing.G1Point(uint256(0x093b6b8e0642c81d929955ed439487d9dbc62d46542895a3e3518f568c7cbbfe), uint256(0x1f48b44d714d7b88c92e0d54c9f3e8e2948b7c7ac56819e3b63eaf4f75da6cfd));
        vk.gamma_abc[355] = Pairing.G1Point(uint256(0x1c49e08ff0a60003d5232a7042986051a931d60ae14fd2bc40414478d98f3631), uint256(0x261e99cc67908be919892114aebd4fe725037b69d767fe23e637761acd811ede));
        vk.gamma_abc[356] = Pairing.G1Point(uint256(0x2ed196603f5f3170d6d412bc584a5fc359685a4aef6b7086a15f9120edeb4657), uint256(0x0c9d87915d26aed3ca856c8d8692bb4cf70f32366ecab66045211b9e7b19a334));
        vk.gamma_abc[357] = Pairing.G1Point(uint256(0x095c16ca75f0f20bebc97d37537801e301dc29402847f6e599ab981e10870250), uint256(0x18c4b2f0f93d6e1bde8a6226395e7edea6159b33e4bcf6ad31e1ac01816a5f8d));
        vk.gamma_abc[358] = Pairing.G1Point(uint256(0x1d91b5f50dc5018c8f81ee7736df568d58a1c19b155117e9bd9fd422dd45baa9), uint256(0x0b6cc016a6b26db93ef5e324970d1df548ad1cec8f616dec58da0093be5b034f));
        vk.gamma_abc[359] = Pairing.G1Point(uint256(0x0859add035a57e73ede65776228b25a4161effaf6bfe83d712b20132a09f9d78), uint256(0x2b8725b7b85743b7a9013f7c2da0b99b7dea7935076e22b19410dc38a3e9bcd2));
        vk.gamma_abc[360] = Pairing.G1Point(uint256(0x24ff0348172236d678df324ca0f121a24fb2312c028aeecb914a72eab6dcb276), uint256(0x080459b14333735144c69b72b124f8b299f8ac2aeb190ba29a5de121a24a76a0));
        vk.gamma_abc[361] = Pairing.G1Point(uint256(0x01fdd7f534e46f3b0e1083c50cb46afab7a9649551cf55b4e1321284e248d829), uint256(0x201f7de38b86cbab4396b60b425d342fd8637802970225530564540ab7ea5b5e));
        vk.gamma_abc[362] = Pairing.G1Point(uint256(0x08dea590f6595c43ae4c2e952e6a9931d4b2fae57787bf7002e876df33c9a967), uint256(0x20140c5d54b909293088ef45b92b9c7a78f869569558e9f09d9d2f18fc46a1b8));
        vk.gamma_abc[363] = Pairing.G1Point(uint256(0x26554b4f64c6bb59c67d18c68ffccaa38e816e69c8495942fc2af2e9c4ff5b40), uint256(0x07a578bb22fba456e8f7dca74f8ec6578b1ead7b89f0bc7273046d4ecce3bd71));
        vk.gamma_abc[364] = Pairing.G1Point(uint256(0x0ae6a3def19aeba7766a798687788346f761c67bb6f3a70310a79e4410a105a6), uint256(0x255a676632977d514a9aabea523540c2ec6dc1fde2fe2d9e19a085cf855553e9));
        vk.gamma_abc[365] = Pairing.G1Point(uint256(0x2b91408d14848617b3d320019458478750450201aef7e9abe8e66901c0c7562f), uint256(0x0b10a54f468a6ec76c0abb177d8aea29a971a826b090b3257582f89abb4cec42));
        vk.gamma_abc[366] = Pairing.G1Point(uint256(0x074c33080458254592c677b8e1280e86aedcf109a9308b7c6d2ba6400b843509), uint256(0x06470c5b076a4e636c5e7eaf0dba40de17fc82987f57916a6bf0416f8d4e2514));
        vk.gamma_abc[367] = Pairing.G1Point(uint256(0x12a3b147bb8bce16ce82541391352740c12ad0f21f21751b41e8b30393601c9e), uint256(0x287b2a21b52f5218137298b25db82161dbc06feca78f4c47f76bc03614377868));
        vk.gamma_abc[368] = Pairing.G1Point(uint256(0x273a05b08a9ec4ff65a8e2708f45f3f2d90c89bb4a470a999beb261bb1942cf5), uint256(0x0dd6cf7cda3dcaca673071de65b4cbabf559b6cce8d60b2149b88af9869e48ef));
        vk.gamma_abc[369] = Pairing.G1Point(uint256(0x0235fcd9f70b59881047fc6fc80d16ac06996533de290713c3bc3488b05e1b57), uint256(0x1c08edb24edba2b177d19993694fb551f9021069d64719da2449a5bc12a63ed7));
        vk.gamma_abc[370] = Pairing.G1Point(uint256(0x0e03c257f5b5fca58a86dcdefa98c62d9707e10464faf020b55309b84a4d809b), uint256(0x1628348423fc1f2620e96bd64371f21d705a524c668ac4a8f81c145078e8700f));
        vk.gamma_abc[371] = Pairing.G1Point(uint256(0x1e24574845167cec67b5c6b68459357b67205e8f948e6431d55232afe6bcce9c), uint256(0x1604e09f0b382f682df5293a85759fe4b5605e6e8e3fd4224c2362016d15f196));
        vk.gamma_abc[372] = Pairing.G1Point(uint256(0x2a30ef79ec04b0683e6103a99019dc638a9a48969cdd5351628cbb5390b8e075), uint256(0x0085bc1f0968a4521b54dffc3cc9e94d44336d33f812f53874673ab37f60981a));
        vk.gamma_abc[373] = Pairing.G1Point(uint256(0x142c474bca95a50f93189169c34fe8654c1a5c6c718091ae6e7e9ba06c2aabdd), uint256(0x100e8b83a94176e2dfa7ddb4210ccdb8d39daf2b30bca92afef82177f56e8b0e));
        vk.gamma_abc[374] = Pairing.G1Point(uint256(0x20d639257891809e981ae9c36e2b40a911221f76f7b3d496185053f0c00ed766), uint256(0x04df4fecfafdd133b6e0c82518c46fea670c8d8c594004e2bd56fec1f9d09855));
        vk.gamma_abc[375] = Pairing.G1Point(uint256(0x2de2f812329cbba468ebf4274da6303e8d05d3d0273b7e2d8a8991a706fba56b), uint256(0x0d85f209a80bbb0f2be3307732d522f1f7cbfb369447a85457f4da34b9d3a7aa));
        vk.gamma_abc[376] = Pairing.G1Point(uint256(0x216c372506279293339555a8f39718b349b8017f7126c37a5aafbffa9a5d17d4), uint256(0x1923c30a71a34e10dbf2687ebd1a0b565571065ee2e35dda6ef171a85c2951d3));
        vk.gamma_abc[377] = Pairing.G1Point(uint256(0x22759032cfe18bd48665fbb8286bafb4c11e39db4db8dec391fb416587948ddb), uint256(0x1b9b78f6ea9623fb75834ff371960bcbbad7ac108bdeac9af1a7ce26506ba399));
        vk.gamma_abc[378] = Pairing.G1Point(uint256(0x0731625813f734358d560689ddd38bc44aa6a8e183ba6179b5e798f08c8baee1), uint256(0x0101b6ff6574b5fec31d0ba0ca8c1fd03cee5a65ec36429cff6b77d40fe94d17));
        vk.gamma_abc[379] = Pairing.G1Point(uint256(0x1f180f30ef96b0eb070333071cb2adcd931939878eb6d7eab5d7a799c834b405), uint256(0x06cd573a762dbbf3ba01d540c51e32f01fe3c9a5e1e3da2ea89f1fd36fc41c35));
        vk.gamma_abc[380] = Pairing.G1Point(uint256(0x22b18076099d547decb0e99329618cbb2f3fd69f75e31ef79d5b809c7e3901db), uint256(0x037bc57c4be1a13154fa3caa7d3cfe886d61b22856f0e94a004fafa8a0851df0));
        vk.gamma_abc[381] = Pairing.G1Point(uint256(0x11b714b7f618bdf02f37335f262af6972148f521eb637b0c668d1150323ae8fb), uint256(0x25585e2456fcfbc1842297d898576448dddcc0923850bc90eb140b2e747024bf));
        vk.gamma_abc[382] = Pairing.G1Point(uint256(0x26e0a32a7d63dae91d3dcad69aee6a9cb4233c68c5d6cf0d4651077ce8d8b81c), uint256(0x073b964cdb0db9867a003904e7e897c6012c8c956d9fa0f6a6e9a34ca4337102));
        vk.gamma_abc[383] = Pairing.G1Point(uint256(0x2651896a0e18e94c067f44ab7609c5a36823524e257842359f8cf9ea7ef7573b), uint256(0x2cb3cc0a7691ee94fbd3ae4d4bc05a827867c4e4278db3446d0bebaf83623a23));
        vk.gamma_abc[384] = Pairing.G1Point(uint256(0x1185acd2b2f0d559c4966375e0c3f74c1a54bf8054b6a3713aaf939e0c9044cd), uint256(0x0546e28ba48ab6ff86fd569802ad82c4163d5471c7d598834d78020e5778f5ef));
        vk.gamma_abc[385] = Pairing.G1Point(uint256(0x18c309620ebb8bf77a1d733dcc80214556aa169ab0466c07e22298f1bb2d4af3), uint256(0x1974b372d2ae3c7f0fe0b8ffafe0741e0f46894ada9427fc565bdc6139a33163));
        vk.gamma_abc[386] = Pairing.G1Point(uint256(0x2a025caa661574729040ed000f266063630efae4725b624ddea9dfb8929b0d9b), uint256(0x176c7a8fbcf96f5fd5c9d011463026736be7d7702cb71e59e5aa4661a05b10e6));
        vk.gamma_abc[387] = Pairing.G1Point(uint256(0x1c84aa4ab71b8d4fd66d0beeb184b41bf1eec0b585a7d8caf348942fab4aabb3), uint256(0x29b2e33df30fe908cc01c9184a50e083290bb3210816ee55377f8d0316549947));
        vk.gamma_abc[388] = Pairing.G1Point(uint256(0x220614407384770d9f35bcc4b8470cd4841a7fe64b80ce67ad62c0e90e37cd00), uint256(0x29f4fd527414cfcf46d1684e4917e791721fabbe1ea1cb6920befa90328d2b5f));
        vk.gamma_abc[389] = Pairing.G1Point(uint256(0x22447672b0778336fbed653aabf87b0977dd400e1f6c938f6b7953a4c72d3f56), uint256(0x0e339ecd6a60b9195fc14822dc5bb0b2cfe62d9b6b3e6b7fa83637857dbab713));
        vk.gamma_abc[390] = Pairing.G1Point(uint256(0x126d513f8f8b90012cc748d4574ae080224f5a5c0f2c18838abe1d500fdfdfdf), uint256(0x24c1d2da14755120e0fae6e1b09a045e29217aa3c1bd253841a0552af32b602a));
        vk.gamma_abc[391] = Pairing.G1Point(uint256(0x2911cb5f9c8258a1414caf4d2604a001f809ac485dab323288dcbcb2b4ee2e7f), uint256(0x04b07b759ff575c754a074e6f3d8ac92b7a55edc6f2332c14c883fec63cb7562));
        vk.gamma_abc[392] = Pairing.G1Point(uint256(0x2cfd70cc0506cef1c11d920a55dab302e811f9d122c6475d3a66f76356c0277f), uint256(0x28e3a6a798d040ea2a498e8c33aac1a8571baecc5a295ca9e55dbea84d0b4434));
        vk.gamma_abc[393] = Pairing.G1Point(uint256(0x1a5dab3abe027188d7ada6580cf9a0d9fe72fcd0884602b0814072cfb9fb08e8), uint256(0x14500f2a9d8b0d1eb0e1b97bb1efa7698e25b1a705d53d5b9abfc0435365e5e1));
        vk.gamma_abc[394] = Pairing.G1Point(uint256(0x13be76db3fd31a3d17d757e796e706d41c58dba253d04c2086ab6fc264b663f8), uint256(0x15559af4d50f9aa92fdb81a7912c86dc7d9f1a2a411272ad6efcef48bdb00ed6));
        vk.gamma_abc[395] = Pairing.G1Point(uint256(0x1c49d7a46595e3b8c9d07c951335bca8570f4418686bcbe4e6218f680e54c44e), uint256(0x10ca2fcc4c90565e4bfaac55054d43e9db5d800c2f4639d078eea66a171557eb));
        vk.gamma_abc[396] = Pairing.G1Point(uint256(0x19b25216e07062b49c603e65e62d09a56151ba7df29a4bf92d6f9a72d7e3921c), uint256(0x0acc668df8c58d3e084a44a618654e7f61b3d839eb3fd0157df5c8eea94f4bb1));
        vk.gamma_abc[397] = Pairing.G1Point(uint256(0x25418198baefb498b9cccec124fc754490a9f0369e91eb2b71881e56ba95da8c), uint256(0x27c21984de6746c826be808a790e333e5183e6f02a9d6742baea2650ec744b3b));
        vk.gamma_abc[398] = Pairing.G1Point(uint256(0x250b3fcf38054ea7d4f5c7e9cc817248557daa21e81ae92886929f89dd6aeefe), uint256(0x0575716cd61ae0a8edf0f77f7d80ac4f03c6ba104afc7b7bfab7a2c31d33aceb));
        vk.gamma_abc[399] = Pairing.G1Point(uint256(0x258ef121722062efecfb07cf40118f29b6f59ea2d5712668cd037786daea7302), uint256(0x0dc86a0946b453aa999c9d958abdb9add45345ebc5b8721de0ca9964424c15e9));
        vk.gamma_abc[400] = Pairing.G1Point(uint256(0x1cd62c6675b6ece4d032098d6610546cbaf74d574a29a175ba695d782647a54b), uint256(0x08fd8dfc821c0ee34d2159c390a960ccf2652f62de94df4eba46098f29a0ad33));
        vk.gamma_abc[401] = Pairing.G1Point(uint256(0x1a66e21e5ec964a379df1000bbfde1ea14662a03ad6e31c98a90b620c77f6a09), uint256(0x10a013d99356e84745e2485b542c778552ef1a29a30b4f4b575c2f804dcf4f87));
        vk.gamma_abc[402] = Pairing.G1Point(uint256(0x11e8482b013dbda38328761e9bf6361da109f68ebd6e9edff75da58b742b28f6), uint256(0x2edf01f9727173bf052b0a9033c3a143454849355afea65625867c248a01e8fd));
        vk.gamma_abc[403] = Pairing.G1Point(uint256(0x0201144d9c6b91a0404cfdc0540cbfd8e2c4947a261e9b8f32d015de7d1b6f06), uint256(0x2c6985a3c58bffb52d0b140fd55d1af5025fc61b1345635993b42f8d91760d71));
        vk.gamma_abc[404] = Pairing.G1Point(uint256(0x2712fe09b70aa8cc010dfed919868170343c6883ea36fe3486dffbbc8fd99051), uint256(0x0453657cc7172d3910f3a677cb518967a419a3a372adabedace57cfb58cad2bf));
        vk.gamma_abc[405] = Pairing.G1Point(uint256(0x1eb94fba297315e931d0e9e5b7790fcbb62e765addef6ab00c2bb28471c5f645), uint256(0x24f968d97213ff01c09cf6feb79757cfd7c18bdd492fb7333e1bab4410dbffb1));
        vk.gamma_abc[406] = Pairing.G1Point(uint256(0x0e1c091675f7840ab06b1f3eb3e53dc611394298da6243ad1e4e2c657d3adab8), uint256(0x2d67a47a5f5f8765f55bbd4c8977a1aa959bfd9e736ab43f2be81d40ae5b9b10));
        vk.gamma_abc[407] = Pairing.G1Point(uint256(0x068fe143c315d54fb3523b5160bc91fc1fc28bd9005b4b068129786624530911), uint256(0x11ea1c1c1ac39cdb21bf2bef230e0df355c545d396ed1dd57a9b9890eb8b1f2f));
        vk.gamma_abc[408] = Pairing.G1Point(uint256(0x261a6b7a00a34b03ab149c64d3cf17dac4fe520492b93f15b176ac2a9021c45b), uint256(0x1f06623703950d75f5648a6ae7da9bab53496390b39e7825193e86f8b0620dac));
        vk.gamma_abc[409] = Pairing.G1Point(uint256(0x1a7db086ff063a7b73234c1e1d7c4721d0693427f902ab8e98dbad60b633f1f9), uint256(0x172b84091cca1111b4c7552e583662c6185c3f3823a91ff10d59c00737a9ab6f));
        vk.gamma_abc[410] = Pairing.G1Point(uint256(0x144ad0dfc83659866fb8999d1915929fb84f9fd498ae94c166ab69dce30d8a53), uint256(0x0c90bc32050d71d9e3750d957290854e3f82d3916482f0ce26e414255382a729));
        vk.gamma_abc[411] = Pairing.G1Point(uint256(0x17c76228d8930af6b42a244abcd9767b1adfaafa4d1ff61c7d819d41f98451ac), uint256(0x1464b7a19dab3555a7819a7586e5b538d5703ce87b054681d4cbf09e007ed7ac));
        vk.gamma_abc[412] = Pairing.G1Point(uint256(0x10be4e695ea889f3ce081897dfbde966d5d79a0c741a848cbaff7820a1f840e6), uint256(0x0139f16b4ad46b36282fae9e34972a6605d5bc2f26037aa83430517ff4ea076d));
        vk.gamma_abc[413] = Pairing.G1Point(uint256(0x28f18ff74ca54cfa988d9995a7b8959962d7a063748cafdd2eb071a7f17210d0), uint256(0x1a7147d4d215d1bbb8bb6d7073115139900586957341672bc66776c22acc91af));
        vk.gamma_abc[414] = Pairing.G1Point(uint256(0x0733ec1d13bd9fc7c7e69f8ca209b4e71f13bf13f7b93639c57604859e53edb6), uint256(0x0560a785983f8a1b327c09baa9bfca689b553aefbcd4af2df41d90701a6c38e8));
        vk.gamma_abc[415] = Pairing.G1Point(uint256(0x249e9806a9e2b67e9f53c6b5802787055068ce09514a1307ed18966b1386d9cd), uint256(0x1580a4858254dc7fdc8a9d59be5ff14e7f569ced03b216dd3d9afb893565280c));
        vk.gamma_abc[416] = Pairing.G1Point(uint256(0x1746c4fa7bcbe410eef296dbcfd442b34a7b282e9ccb9ee50e08e5e05609a678), uint256(0x1a00c7dbf90d4ced643380e16889175fdb15423ac2aaeb3cd39734266b2ed747));
        vk.gamma_abc[417] = Pairing.G1Point(uint256(0x0559730487065a067ca1d995de77e47376a1e070a084dc031fbea74e0c58c47d), uint256(0x04612de1ec37f6a450684e2faa9acf5936c984328941faf2c4454abe102eec55));
        vk.gamma_abc[418] = Pairing.G1Point(uint256(0x1144e2af6f56edc6fe932fd5e2f2abbe67afa335796a07280f7cf88c53997ba5), uint256(0x0d49026927a189a14125c942da62523383a333218206371c6ee0946e9fc9ae3b));
        vk.gamma_abc[419] = Pairing.G1Point(uint256(0x040707f733daa95bb7274e8161c7f91f58fbe5fdea5d47c419f6c20386f17e55), uint256(0x114a4594c2793644123629663c9b2914b916ca637eb9a21ec37b1fc8dce41925));
        vk.gamma_abc[420] = Pairing.G1Point(uint256(0x2b6fc4d9f073322ebbee5927befcb24d541fb7663c1354ce62bbef92bd49d5a6), uint256(0x23756628ebcaa8ca363d22925ad6377515476ceb190d1fff17cb375d40d4a4de));
        vk.gamma_abc[421] = Pairing.G1Point(uint256(0x1b936cc9109f8f3f5616288fa96c16886c0eaee26d3b79579859b2ff75234582), uint256(0x0d90487a49b65f8bba0ddfc4f04865f100350ce45606a9c50cbecc2e7885ffba));
        vk.gamma_abc[422] = Pairing.G1Point(uint256(0x204a163cef975d5be28078f07aa92dfaf1615b29f4a0fe20478b14755019c39a), uint256(0x1fe5ab96f0a3f8ffe99d042a473dc18259a6f00e1cc691fb407bb655792dfbd9));
        vk.gamma_abc[423] = Pairing.G1Point(uint256(0x2be137be3feb13f12bb2ca6a3f82d4615a16f958575da09fa84a3b672d256c28), uint256(0x15d62d7fef13c395123d5e81dfcfd1c0d19ba91c7f99b8d30b27a3a75fdbae2d));
        vk.gamma_abc[424] = Pairing.G1Point(uint256(0x10766c54254e914be3ff1da8aa4dbc79619979c08af81bae6238cb499e286755), uint256(0x2e17db80e376c92e9650bfba4e8d23cca162d52230bbe9df6f675a9f5dcbdf76));
        vk.gamma_abc[425] = Pairing.G1Point(uint256(0x1da4f84470cf581beff9eb8d4cf514d94a37764cb9a19dcb8f17122ba1d30645), uint256(0x1ad9e57b0d406776c46496f60e8feaa23f190a8159cd173693384cc477558ed4));
        vk.gamma_abc[426] = Pairing.G1Point(uint256(0x226a08c47aab44374ed34c55212c5399cc44937cf51e9611b7b09a4912882040), uint256(0x09c9b87ff4faf505261dd039a0ac8118e4a8fac4c8ba660b5c230804f91bdd74));
        vk.gamma_abc[427] = Pairing.G1Point(uint256(0x22004d4e75139015c8e0ea2c509d3facf6c204a5b34554fb0523564adc56524b), uint256(0x0c7b3f5d3ab6ab202b38fe55c4cc99f776b4c74756349c4960eead564348fd6b));
        vk.gamma_abc[428] = Pairing.G1Point(uint256(0x2185c41d9b41940acea60ff43fc90c8e64c4dcd2b4fcba2b3303459d1b9027fc), uint256(0x2142c01f829f00e2aad4ec9f49aec89cb1497eca14f220e980a5e9c4ed361833));
        vk.gamma_abc[429] = Pairing.G1Point(uint256(0x0c97a03b38d7c0aa6bfb39696651e698d41f94202c94ede4f68409dc2af396f7), uint256(0x292d0ea19f408f3c26e45f3e4d7e2de043ae993917fb357de980f5a0a61df97a));
        vk.gamma_abc[430] = Pairing.G1Point(uint256(0x19e1a98e2fde0d555c98fd62c2c91cf0bb1a243af174ad19c80d62ae33fa6996), uint256(0x0e6174cc03048bc4408879d30bdd558f4a951d51fcb0dc324914aa8f5515436e));
        vk.gamma_abc[431] = Pairing.G1Point(uint256(0x1eb557f1e0d0c6f698fa6bcc7705591ae07f366baf86994a1db40f62071f014f), uint256(0x27e9508f9add775f90d7a521d1860d2a58314c9083f57a3203de50f19c9b9951));
        vk.gamma_abc[432] = Pairing.G1Point(uint256(0x2e2828b00bce87b9d877b29e341d309cd8e56b69dcb8c68319f5537236ccc7e7), uint256(0x27b83e60d67633492f48caf29a58adef591e6ccf138222d8ec988144a3811a86));
        vk.gamma_abc[433] = Pairing.G1Point(uint256(0x1f85dcb49c497f4ddb41c2dfb57219536565afb83330ef76c76f183cb00d5aad), uint256(0x0d5ef2c4b750aaf58cda72dfd12a8ff9820eca2946fad5cf244afc8b06043c01));
        vk.gamma_abc[434] = Pairing.G1Point(uint256(0x03b520ceac813031bc894d54bbe565bb51382658a897445fc3ae17463add65da), uint256(0x25f64dd86d78c5a22c7a2d0429f464835663c6e8732b62221f42bf2af5ef32ad));
        vk.gamma_abc[435] = Pairing.G1Point(uint256(0x230af92cdde777fe94a43e8e55d1d87c59b92a7b07e618730714b7141ce79b9d), uint256(0x0a2db4780c5b8ba2ee40b0bdf1d61672387d607ddea2c29c16dff8d1d73e6815));
        vk.gamma_abc[436] = Pairing.G1Point(uint256(0x04199c19e54b3be35e436b26e9567b92af85ebfb79245091b559f45851dec393), uint256(0x0e66063bebdfcdf38408d63900214fad9dd6ad02f0d6f057355dbbed8527fa01));
        vk.gamma_abc[437] = Pairing.G1Point(uint256(0x04becd8a86cbd5b12832ee66760121710d2d1417472c50b6e19ffaf452159a4d), uint256(0x02b0d03b92dc2f6297bad4b26bafcf3d78fc6e01097ed2177271dbacfe5c93bc));
        vk.gamma_abc[438] = Pairing.G1Point(uint256(0x1f7d5aaa5f5d0d53b1964375dc99dfe684993af8c0ce368aca5fa49a52ba6c87), uint256(0x2b65201aba549b76d92b51b0894f5e0a6df33bd8590e893b89b8df72d28fe39f));
        vk.gamma_abc[439] = Pairing.G1Point(uint256(0x1811965f8e8940060fc2174962e49400ad96819caf7ba7ef964c5bf5928adfda), uint256(0x0c061277e548d7d22f57317dcdbfe8df7a75ef3695f2524275c5771f72602499));
        vk.gamma_abc[440] = Pairing.G1Point(uint256(0x0d3a3595e9dc94fec46cc25988f36bdd226c6838016e8b11d8e125fdd97d8ecb), uint256(0x016b01aa39e1ddb26322e41e316ca59c2d2c025cf3f609729ecfc8315fe2d3a2));
        vk.gamma_abc[441] = Pairing.G1Point(uint256(0x0c30a618c0db1f94c2fe28cf256de6aad8a9099b78da3da3d719260192fe6b08), uint256(0x0914ebf22314851d2e9f2a54b670b50866fdbab28cf7b8e557e7046ec3876c15));
        vk.gamma_abc[442] = Pairing.G1Point(uint256(0x1f6f93d9194e11e1ee5ad76f6fa394e03b4f1bb46091bee14c594b9f8083a579), uint256(0x22bf0de416d7d18d6113714ec313b3969c08603836a0b078d11f6974bac2e98f));
        vk.gamma_abc[443] = Pairing.G1Point(uint256(0x10a8f6f0e06341e0adc80c5ab0cabe9f6a88506f348fc1ba13b27ff713a8a9be), uint256(0x038504f5d20300a209dfc106d493a20caf37c381ddb62d0215118211815439e1));
        vk.gamma_abc[444] = Pairing.G1Point(uint256(0x00e8f865d0e808701f4a66d7fd5f57432aced4d39e07bd2627af62b8ae47a4a4), uint256(0x29e169e2ca927f131451a072b14bc520d8f2ec3f0cd0ea04985944170654ed45));
        vk.gamma_abc[445] = Pairing.G1Point(uint256(0x0676309e0be6d52ce0471930d90c32d01e03c805103ecf1198fa57fc34941495), uint256(0x2c769b62040b900cf793366c116424b9fbf55bc8de050061200b08b4b19bff18));
        vk.gamma_abc[446] = Pairing.G1Point(uint256(0x1be3a6178426ce6231547da7734198fda2b9e935df764a286a13b32ae61bedc5), uint256(0x23515711f6bae1cdd306f8607e5775515f2dc294e81947439caf9fadd5b125a1));
        vk.gamma_abc[447] = Pairing.G1Point(uint256(0x24fa233db0b4df1a2a98c7f67494c927f64db4a7a89227970e88bdc4d59c855c), uint256(0x139482d92b542180475829dc88a7fe37fc4e2d455154d8d48bdf5763d0db02c9));
        vk.gamma_abc[448] = Pairing.G1Point(uint256(0x0e6363b4e64104ee9c2f4598367512a77fe89819ceb98ae112095acd5e314cc9), uint256(0x10ad04963e6704cffb8f1c5c71d9161df5b6ee89246a87fe6ad062b221e6179f));
        vk.gamma_abc[449] = Pairing.G1Point(uint256(0x2ec06da7bedba3706f74924d69ecfc86e520358c700b46c1eaf1f2104a245444), uint256(0x1f8440a9c978df501045455e2c5cd47d0bf87e435f87dd10be5ed557b189b3ec));
        vk.gamma_abc[450] = Pairing.G1Point(uint256(0x24a4c1faf7ec369c586281b93adedec3bb0e574b0c2703c1247f83f476a22b69), uint256(0x2d1b617237cb1c8fbc4f09d1aea27f4772337e38deeaf829e4c555a4b5a81f00));
        vk.gamma_abc[451] = Pairing.G1Point(uint256(0x1c0857394f6a4a27626b81b605936e07ded67991f3df7ce932efdf6b23a5bee1), uint256(0x13572977d6c6226f63af0fd8102dbb00938af042ce0bdd724cda55ad735c5b0e));
        vk.gamma_abc[452] = Pairing.G1Point(uint256(0x269c8490dbc59f0bda9d2750cc11679a9f126359e2beb2a958c048f895ed8b63), uint256(0x28ccf7675ff31dda8a42c62b2efd98e1d2a1d8d1653520200fe815b94b1b8159));
        vk.gamma_abc[453] = Pairing.G1Point(uint256(0x046791551d3267dfd642768dd70f8d0f81a2b11d065cd274d8d8bccceb6a0122), uint256(0x16b71449994afa07257083ac74c12e5878e3fb9c994653e090a169501c73f742));
        vk.gamma_abc[454] = Pairing.G1Point(uint256(0x22b66ac9b7e105545db128dd08ed7eeac191785e06eba75df08a528be2eac8d5), uint256(0x30142ea976e36bfe5fa63d701e1cd79beef2936c5845480e0ff52aa86495ddf4));
        vk.gamma_abc[455] = Pairing.G1Point(uint256(0x2b18b4b18e5d22be24d12e513c0ee76cb751d4ac94edcdbdd38933ecea7b24c6), uint256(0x104519d3329b29590e2dd0d50bd195b1da16c50ec9ff30e0264409b6cedafb7a));
        vk.gamma_abc[456] = Pairing.G1Point(uint256(0x18e8985b198f98a1089da4eddb7c8b5c6e91a44e6b7f7077641c39d6be54c0be), uint256(0x09147b78e96959a33d9710f0a3d76def3b4d5bde457ab3fbbb53d0c9eec4e0e3));
        vk.gamma_abc[457] = Pairing.G1Point(uint256(0x0764b3dfac43e43bed79312487d44e01d15e9ca7dc15185b98d2aaddee086c7a), uint256(0x19d0594e9efa6c0210bd8e1e85a63925583152be487315e1bb177bd27c2f72e3));
        vk.gamma_abc[458] = Pairing.G1Point(uint256(0x302b18bd3ae7ed7b74cf7c50d138695db2f6b26d4bf4a3a729738a96abfb9b51), uint256(0x01983785acb407e6b5eca5f396700cbb36c9b2981bcbe566bf249a75f2070599));
        vk.gamma_abc[459] = Pairing.G1Point(uint256(0x0e30da5c4d920fd46d77f8c44d5dec89f6be28408fb47fcdbdbff0c9533e0bc8), uint256(0x16b7649e2218f8a3f132f92933da6ebb2c6cb00155ec5c26bc11af986084ce50));
        vk.gamma_abc[460] = Pairing.G1Point(uint256(0x2312cf51e4fea9373753e9161391bbcd32cd73c78d45149eb0ca8d6ee527dd25), uint256(0x10386fe8a2cd70caecde8a61fda7d43c8287f5b7f9a350ddc0580d66771d9983));
        vk.gamma_abc[461] = Pairing.G1Point(uint256(0x159ab18c0c6702dd0e8ab13144ec5d7e6499cad19d647435321fa2af06113720), uint256(0x07bfdd132535a821edb6cf982a46c75cb8983abf07734394b1826d7c3bb30aaa));
        vk.gamma_abc[462] = Pairing.G1Point(uint256(0x05b04b858d710a10dc0a5f4f764c89060d3b5b7b5329bbff87baefdf9c396f9e), uint256(0x2acbb4c24972edea276236afd0aa47214ea844423506f175159786fc875259f6));
        vk.gamma_abc[463] = Pairing.G1Point(uint256(0x2bf2ff1be50a18878b56b4b8e05c67596ed9bef937e6f13b8cf67d604f4c128d), uint256(0x26fc7e2cc195092a3fd2d002ebf64faef4e4c79b37ed48a92b4b26da7c6b4664));
        vk.gamma_abc[464] = Pairing.G1Point(uint256(0x01af44d34a6dd291e490261a43a59ddf795f27f1158fd44c97e923465cb1f91e), uint256(0x17a26a58feb32142737fda75c0fe7d15e946f97f3ae0b033d493b09f7c5ed7a5));
        vk.gamma_abc[465] = Pairing.G1Point(uint256(0x1e50b427f2725d48a008cddbe9a4d76efa915e2fda73724d9f0a8dd911deeb73), uint256(0x0e1a8be570108976c732a1938427bc08156a51128a3b9f5fd633bae7525b8b75));
        vk.gamma_abc[466] = Pairing.G1Point(uint256(0x10b2946cd31f7efd471b28b0e7a04b37cc956836f8ceb3ad605e8165ed4a80b7), uint256(0x0d51f2a3aafd93e20ad8dd9794d27de43dc332ab6a84e167c2ca14d5000f7331));
        vk.gamma_abc[467] = Pairing.G1Point(uint256(0x2f927a34de91cfa033d058a32be520b0d10ed457915abdc3c4504b3bd1b99721), uint256(0x0ecc61d1edbdc108fec9e2193280fe2d333f61c426cb131e997bd52b63643e14));
        vk.gamma_abc[468] = Pairing.G1Point(uint256(0x12356ed6a9f0ff94c3b51e417718d4eff055818ebd28f046e95179f9acca6311), uint256(0x1a99dd7b7a4fe98582b415b72551515bd4eec392cccafa1d49f0389923dae71b));
        vk.gamma_abc[469] = Pairing.G1Point(uint256(0x30081f093b94cc8d93c73ff9b7453577239a74aa80a325fd01fcf490b49bcc28), uint256(0x0bd320b322daa91be4436cc4bfef638492793a49ec6448a1c7316005f0fd7e8a));
        vk.gamma_abc[470] = Pairing.G1Point(uint256(0x14a446c9a179004b60f430421af5572f8654a2d87a1ddbfda46f7983a13a175a), uint256(0x1d721919525b1c75eb55b72b28d7e37fa47f119ea951e5e63d9542354feb0e5b));
        vk.gamma_abc[471] = Pairing.G1Point(uint256(0x2102750fd529d63a4a5217e15170bfe0868802f87f919efe69785829f0bff4eb), uint256(0x1c7f9533bef84537c861e01bc23bca441f633ea63e8b1a68ee729376fafa44a3));
        vk.gamma_abc[472] = Pairing.G1Point(uint256(0x0532eb91232c28641033c0f2bb2f08f59a46470c4d101f79b5162fdb39cd7eb9), uint256(0x240d517aed6c66b3de15ce02945068f766c180389e8b24d5e121a04e96699e71));
        vk.gamma_abc[473] = Pairing.G1Point(uint256(0x1ae89ca855a80e666947b01ef7503451e2953f489707ee2f2722a3d7fb4b313c), uint256(0x1a60c836d1cfb532852e805f587093b8eaf88eebed5671c75ba6cef01fa5cb31));
        vk.gamma_abc[474] = Pairing.G1Point(uint256(0x2bf77f48f2078a1b25058330df6ee32b8a2e5c746283eaacb17928b4e1ebd429), uint256(0x199b5aaf8a5d07bf48f68cd5615ba89f20cc7f28d4629d9a20781775e1b2eeae));
        vk.gamma_abc[475] = Pairing.G1Point(uint256(0x047b3a9834a3489d93e44d775ba97f4e67686b7b969fd4db0314a8027b733e10), uint256(0x104b4c474130d4c74919ef6c09a99643e5bb019efac878998a1b461dbfb7b74a));
        vk.gamma_abc[476] = Pairing.G1Point(uint256(0x17108a9a8af734ea1166c27a3e8203596cf12e7a755f7d74424d922019fa5fd4), uint256(0x1195559d1514b92578867281e6be8fc04339007e924f769de0b68f7669b53b66));
        vk.gamma_abc[477] = Pairing.G1Point(uint256(0x0f7def9d74c856218abbcb0bace2dce9c4c2936e38adb22009527cc28b196f94), uint256(0x2b03a6c0e6be5585a68c894688d948f7673ed679b4e82df0c3a604c3abb066d5));
        vk.gamma_abc[478] = Pairing.G1Point(uint256(0x043ead7d30cb98a61d7dffbedd6cd0021b11ac35149c50f60f249c78e662de65), uint256(0x2daa66f71b07116a9103701b8500dbf8fbc5832cfb3d8dae9353ce663d340f81));
        vk.gamma_abc[479] = Pairing.G1Point(uint256(0x063e22e17c9923bdf713e73bb0e2f8fb3c5278993cff62d689bf19d25a8b17b2), uint256(0x062e906afc8e1dc69a375ed69c3fcbbf5dd33bac10b06178d3b0f475641dc256));
        vk.gamma_abc[480] = Pairing.G1Point(uint256(0x1f775f1567e0949be89525ae95d8f47c78b6c367e74400a56657e7914781c0a2), uint256(0x251ab86ec56ac13b0d50abf40fe3cdb71f00d4ab1b5352097fe66b3b7f932c7d));
        vk.gamma_abc[481] = Pairing.G1Point(uint256(0x1ab96301b05df0f4374e771934b8e93d2cdf07812f5a666e54c245af1b23df49), uint256(0x00275736b4b18bd96ceded2f38d481208bd2a86f44daf188f2c7f829f1e177aa));
        vk.gamma_abc[482] = Pairing.G1Point(uint256(0x2c95f448cff0f93944692c02ce25714d4e8dd8add1653adff29074d6f3c57a5e), uint256(0x05caaf7cc4eb1bf4f176ede5039100c4f60a5d008a0db3cb275c24b7b76a62d1));
        vk.gamma_abc[483] = Pairing.G1Point(uint256(0x2a718ba3c0a6fdef9a7a5466fd0d8a0fdc3b7692db70b0bd521fc191f2726abc), uint256(0x049978d7d3d18d8b89539c718649209773930a6814c7f5059cf7314865a6321f));
        vk.gamma_abc[484] = Pairing.G1Point(uint256(0x29d50440e2834813063a10d3dce69d4699b6b3cc89a1108384caabadf0f88f6d), uint256(0x1404d2c0eaea74b9bb59006e0558b1e94a43fa5f7d31ba1a3135ce22d278f105));
        vk.gamma_abc[485] = Pairing.G1Point(uint256(0x0d01ecefba0f9f3686d7cf8b63a186c43a68304c5270f17bf4d85a18dc654d65), uint256(0x0d566811708b1da899dc5f6b248a0dd167a9f847fd0b6cf340d25a6fbe6396dc));
        vk.gamma_abc[486] = Pairing.G1Point(uint256(0x2120991ff47af906095c36fe556e3dd7a457c6f4d8a9c414a450d27254d808cc), uint256(0x045576e1c06c4cec039d7a8d0cce134366f12c8874c37f748f1d955a25e75cbb));
        vk.gamma_abc[487] = Pairing.G1Point(uint256(0x0d3788f73c5fe9e1239f22720b1cdc5f33a45099d4e80556b7b07e71f96b39d7), uint256(0x0ec04592730ec5f037fa92163a1d7cfef0c05eacb81fd7250d70a0c07373f346));
        vk.gamma_abc[488] = Pairing.G1Point(uint256(0x035912ec85ead40ed8507d05477f41baf5edf30bd91201b7bca348c3ca471290), uint256(0x22e47652f0a96e3971e2fc24403e9626abb39e20371e8d9e1f509167c58fa207));
        vk.gamma_abc[489] = Pairing.G1Point(uint256(0x027b1d83eb15fb3b1a2ab7ee2210bfa9a617a710e8f9e2010ea4074aa8e3eb60), uint256(0x202bd9fdd681ad06e63d01874654f116af63d3c3af9c9e7ed29201f89a7bd783));
        vk.gamma_abc[490] = Pairing.G1Point(uint256(0x086bf282538b770ceae5fba39ea0f899cba7031ebc5935aca8bedcac60d2f474), uint256(0x242b3e034ce62e5f66e66ff12667eb8ec588975d105afb3b49bb1e4a972a40cb));
        vk.gamma_abc[491] = Pairing.G1Point(uint256(0x0e5c5c31bbc03385514ff5abe6add99c677e6e6a8a20edf42c67c77be2cd87fb), uint256(0x2986b8082f2a5f1b8316413785ef04d061b2b76b4de889ba99ae2447a63d429f));
        vk.gamma_abc[492] = Pairing.G1Point(uint256(0x103e439a81a269be812e8e677514b5b9b2d39d9b46b4c34da3589e93cc4df1d8), uint256(0x1fd5f7267c091a2692a07e209377d520694d95da280d63f3fabee5c2a731a53c));
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
            Proof memory proof, uint[492] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](492);
        
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
