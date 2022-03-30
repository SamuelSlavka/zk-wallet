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
        vk.alpha = Pairing.G1Point(uint256(0x05ebf100c72a43d0e8cc7b03ffc95ced02164e024b51ca313519d8268a3b0b3b), uint256(0x1b0a5334d6c4d35feea0d043e783c8990e251f65ea4874cd6d3f529f7d37a7e8));
        vk.beta = Pairing.G2Point([uint256(0x194c2215ee1e5f383564733ee5ae1af2f47c8f57c85971c28e08d022d5bab6d0), uint256(0x2ddc2ff31c9a01734c1ac39f67e47859cf63367f247685f6cad2652e7486f3de)], [uint256(0x2d59a1da771df48e2833b2fb96f3343324f18ea99150675547d387c7ca8e0413), uint256(0x1d1a12507985203bdf853d2b9779a086baddece578a51cffa8eb0d1efef7f9ba)]);
        vk.gamma = Pairing.G2Point([uint256(0x1a4dbdd9422941bed375deb8dbb2d604e6aa0f29dd434f8084add5dbf533f8af), uint256(0x1367cc5e167744d011d6f7f3165daa0231f9909227d6e51bf1a0a6d463a5a148)], [uint256(0x189230c99538919d10c26e6443bf0749728788707c77e37f40a3f58499410571), uint256(0x1346394867ffcc641e687990dad92417b0d8f4f5e21ea14e4390537d6cbb5fff)]);
        vk.delta = Pairing.G2Point([uint256(0x19b9fedfe9b90faaa0dd1a6bac8d29c5e93936ae9b9db8d1cfb04f1df37ac81f), uint256(0x25aa86ffce73b1c7084f253d63fc13b26221c1b0ba8ce69a8a0ee324d1741a8a)], [uint256(0x2577cdeb2e692a9715f9e565c3f41cdb568159689499d85dc21fca1807c62333), uint256(0x2118ade5651ca9ccdcb8cab057014e33428699bc6b9b4d4ccd1ebb177668be3a)]);
        vk.gamma_abc = new Pairing.G1Point[](53);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1e5fd911d8e56fc7d01752b139c4991396985014a04af11232f6f5eaf7dbe106), uint256(0x291ecf1aa7268ef424cdd21cd0c1c59713a6ee71a4a0ed9a28f18e0827c47d95));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1b171514820e8cbb5447d2c1ee015bb0fb8b4885b6ca2e93fea2aaa342796ff5), uint256(0x0195e501b0a1ea6373a172a2f2e83879089260c9b8b867c2a7fa85ac4bf86329));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x273468bd72904793b422e38a0976c8b58c89642de1d5a8da7971bf3654e1bd92), uint256(0x20a07632f4909f9d6934bc599b37e6a11ade04f3edd6332f8551d6d9782e31f4));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x14ca3cb631c271dfebe3127b356d1baba3807ed36f4d3075ee22183fa84f6c9e), uint256(0x03d1339ccb37d7aa974b25ffb9dce79418398ddd376922beabd1eb610ed4cc93));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x03a8e8558258ad90d7bd6e350a997b5faa69052848b49b762002c8217423efab), uint256(0x2dc2552228f8acbd051e923980b1a4f1f79619a41a2b44227a14a0b5c1611b6b));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1e30a76eb2889034e778a37017f02e2bdfe1c9a969a9844e4316b2707a141e4b), uint256(0x21ba683e02a420f52554e976a02a45e506ee5c15ea5ab1e6b7ba9832f5cd4e5a));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x11e5cd1b7813930f2834d2dbfd04b25cc9e6349ca7b96ef4e376a8325f0b8d8a), uint256(0x09ed1dc912b751b4ef01b1069a75df6e27cb8100757e09b1036235c2c1a3ba55));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2547b916bc333e4b73df444c9ee70b7e6742ce9e8126c0ec4b99f1296ba1ade6), uint256(0x0a7460774911f53c6f7279b15e13af6be0e48271211feb2dcf11af5c9b87be47));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x14aa22ea06a0987189caf15b55cd9066e49d057acbeefed141cfa147aa5881b9), uint256(0x2a7ce5c215ebf6dfb24ca298a70b214e1af357036d95d5b5fc0d4d2efe5be54b));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1c3590b269e5f426bcf1dc092be0e80216854ce6d69df1914fcfad66b0d396a4), uint256(0x206a5aa764f6b64b0fbd1c0bbdeaec0933eb1321606147be50f6be3c4325b1e2));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1cd7cd31026c2a7c545fc3f8434aff07894b66e44bfe773f4bd89e814c246e0b), uint256(0x0b897f68f2a88279d74dce39c79d0b501ad4c9b144ad815a12b660e312f7c9e6));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x090231670024cbe49b3b83cf2966a4fdef6d50c8ed2caa8c6a3b643afdcee458), uint256(0x02e51ddc9ca77123d9b1e127d64b8386ea231f238250dcaedc1133fe6742d7d7));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x247b6580efaa856098af77c922ce695c73106bf6d1e59d83756e5be152e8e311), uint256(0x06b11ff3ce2716173e782fbf3cf1e40eb7860ac63b7129b8205b1e9fc5da17aa));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x00d2b4b45e6285f7c4c0febb4d2417bfcd15541dac98de9e4d2ed4016b90aa61), uint256(0x26bde4707036ff4c7ab694e0c82fcc9e2b3d19072578d95d837a1639056afed6));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x23b80bc7fec5aac0c9b198bb548600d9ba66d5e221b0fefc148acfa72dd2876d), uint256(0x1ea9ed7b4dca71d104ea03375372a5220f957a59f8557c19e96819aad94d3edf));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x26014554a77aa4045c06b83d2bc085d8cc069ffae5a196c27a8d8db8ee37295d), uint256(0x24d46d7836bd241a4f2bf8f2d39d3fc7c3371fe7c839bd98513ac3f6c67943da));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x1e93b1ed3ca4ac552d67b35cd6d6d4b394ffdbcafaf735e2d74e4e76d2337883), uint256(0x2636bfe19eb2418cbb3f2b6f6e1da8ab840c55cac9f9b221d1a258cc018d0781));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2403f4cf0929101fefa8cc94dfaef4f2b95c409adbd481df0e3b7b2f67e983ce), uint256(0x0b12c75236e2150f49afec2fac7886a940cf58c0006e89799eee9ef28e3a3721));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x148c8de4508a98f787cfd4e8c5523c736eadf209846d0329f634d0fdf2cc7c32), uint256(0x17e6a1ac7e5f5c3aeabf32520b4258ae3ec50ab6ba134a889062acb84cb09870));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1598af81af510e301862bacdd87f377ca28b2ca7610cc8e66bc914d4ae44b715), uint256(0x1d5484d567cedac4d7e2d5681200b2dbe629f24ea2750cda90053e3b0e93324e));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1897b552f325a378668441224d885d5bbccde17b3d441243a0ef57e03d3e2a9a), uint256(0x13b1f4512aee2b5ff2ec9a1e1c71c3c605f4daadbcf4ce9815fee8f2c1d758af));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0a44e4a65752cf06cc9bda096d6573e2b9ea5a7652277d74ce72e0abcacac912), uint256(0x132e48bce3de353736387ef96280a52557444bc0394357e0096c34a1e9f73d0c));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x2a3aa6f530d9d0ef3a8a25db3106312a9b8b2a4dc4dccb0b9e8c71c0eec986e2), uint256(0x09d9cba57852e04c9ec1dd25ad8a3303245b555d8f0a3349d4561a42dc98d099));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2721bb694cd44ca229527f0f58c7121871c4ae9a0a0fdb9d04a6d63c0c55686e), uint256(0x204b616f1d192c7f4d7da1f0b63adec9780c142650abd2d027e7359df2b029f1));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0d4793dda7aa7830576c1b560e62f6d132b36798f64e0738dd3ca3329b528348), uint256(0x1860952952e369b907088e3f53845ee2c703cd5a899cf2e995d81488b0845428));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x0fd00e36ecf6557192c4d938386504540aaf3f42a979a721fad68bc80eb37cd0), uint256(0x1745705e572b501ceb3e5b919dfc094558f7f864dc5149416d376df95a139231));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x230e303678e7e5cc60788e3991b106c4a9119a395d4552d83c6d4c52b9c8519a), uint256(0x2c076bff730748221d6f0fb13608be018ebcd1a8a233f4e6f1295c54efb4f609));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2b1b35e9b18b5401b9eb0b99110180e71826ea1030f79344b49699acdf26163b), uint256(0x1958f80ba8061168b2440a0746c76deac99c683ac5f7d034688fbfc5e4484882));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x2da5a580751bf8979a21b8308f73954ca2126d282df0697dc63f84deb3bff224), uint256(0x16ed183859bade5357903deb25f0696b9d0b2655ce4ce6748ad663e592344901));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x0f9d13ed0d5ecf74b110e1ae7e0bead9ef0439d379f314e899207328381f2d2a), uint256(0x14eff9fba78d0831139c8301fd3e271bb08f6ffef53d0951a6f50f83a6cbabbd));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x07747f08463087b63939d98ce94515dd1bc301f28048e9c9b059afde60a12b87), uint256(0x1c4d9a2983e2051e9170e8f7b2c1bf9f20811d678ed150c1ae00e93233383eb6));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2d5732c555409dadd42689f5fade9326ee879aba8f11d6c9cfaa2b029f0b4bc1), uint256(0x15c167252a6bd21cd685d3c42672ba17727d7c88a84ebf8dd6aa571a29cd24ed));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1528f1a7de1640a03bd85e391479ec0c59359ff6a5e8ce305a388184bcbc966c), uint256(0x0882c3702e13258ba69a31e985404541c8b8124be169a3797ba1336f462ec13c));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x233907986f1e642ea917c38647a709a81c78e296e316d8c2afd9ad3d65c246c4), uint256(0x05d4474f9696850265883baed9944d6ee17da6ff7c6fab9611c934b010b04960));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x0ecc3ea9036d4af568d1bce05c22a38c52cfa148e58f505f8caafe019924f99e), uint256(0x056cd4412c949847fe43f7376dd987dc6db738a9a12abc090aa17100919767b3));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x2c1478b3f6416caf738dcd529b2325599c3da37147e214b71638609da05d2ed1), uint256(0x1f1b39cd5b18ac4285d838ff99ace1929070df33c3089c50bf185daec6a8154d));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x09933b389b1f0c63aa11b8b3ae8fbdfed11019b746665b1bb3dd364f00eec51f), uint256(0x29f55987b4c9d683a279e368447fcc8ecc3f13d2f376af20b0ff4aad765354c2));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x14e9b96d711cbf16d01432e73904ce811fc9dbd156cbff85eb85d2097b1785f3), uint256(0x0f08dcdaba1dc52c3b29b22c587d8ab6edcdb4f69ad28ad280c7fbb4bfee94b1));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x2f79a504409bee94a1ab3074d3343b0af521207c95b245e946a9f9f17837c0c8), uint256(0x214cf41bfeeb9a710722feb1bcfb59a34fc4c360bee14094123b96be38c07099));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x25b95349e2abc9c345159db927300c4292d0d0015ea01bf2645cf684af3cb506), uint256(0x21e18bc674e7a1a4f3ff0516ff719d96809d9d4e651fc83d4f1052beaf0ccde3));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2227dcdc2aaf2464c77c558489abdc5dd7110256fc8965f0d87a0c6a403ce56b), uint256(0x042d74328b1c9e13f3ce54c6eeea7354f201425d68a5727dcb614112522ddb85));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0fbc70c51242b1f9e6f98718826e0316b1446d5cc103d1674d0d734b2b26f167), uint256(0x1126bebd8d884956c13cfd0b98b59179e81a2bfa033a2674f1bb7530dee46be6));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0bee1df95ea5977a9015129f3b9f36a301f2b97fd7027b4ced7057d89a74ce43), uint256(0x2929ff4606ce833929911054f0a43bfa9ee1a2ad52be564ca08dfa07835f1f27));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x1390415c958abcd1eee95be3383dc102d04f9228dfd845382c6f7bf3b2866a57), uint256(0x0ad3239caae4522fac32e2f2b169ae2d0c56b9d90665ce2a3a09164abcce1777));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0952af0db90bb79329a4c0cb95cbac8b0390ced1b0386a508efea6090e8cd87a), uint256(0x0e4ddb2448912bb53c819b2226851a52cc1110afc130af8b9577c25b9da64c95));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x29c18047dae4dc3e096a65d66ca5edf298c2ce7a18d8551c85411b6e6ebc918e), uint256(0x2ae77a2b4e7820e103c454db073f1fa62b42b632f9b669aaa6acf9e41d58ab1f));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x147e224af018e930225338346f835de52f9d873b18132bac318bac171fb125e8), uint256(0x17d1232761803c00c3101fce185bf00c2cd882553057ee48b6837497a924c55c));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2e9039aa522c8023f72eecd09441ae247b1f81e0061a0a601938471c3a295dd8), uint256(0x1447d45c2ebed6df0c34e8ec3027387c1ac4f5621914a55c5721398b18676675));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x2f7516298809c8562a3fa37155fd594c80ce078f9702da9540352a7cebe7318f), uint256(0x1828a0c54dfa0778121d55e4a4ba8442fe61af81a84383a96db1d4a2622a51d6));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x2298c13d4c30d16747417421ea41c633c21469d38ffb2c64a39eac1a80f7962f), uint256(0x124850933731017e6903d4c1c1a823fba9c0e3714f4fce0a88ddf05eaf283b0a));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x20014e27a20ad551f445e301fc6c9a448ba6f369d24f7ac1f93daeb41b04703c), uint256(0x22c47798d2c0cdb76a087b75378a0fb69be7e9362aa57744ed7b4debde9a2071));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x22d0a1b0c339ae7266d8ef50a9336eb45a0cd760c711a3f2696f25b691d8270f), uint256(0x21c834dc82ea0f995e85583805be2cf06a492af996d0ef659e6dd571181bafee));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x1613e48a6c266a2c6853ed121fdc61f8539a383ce30c388bf87418745c65b4ed), uint256(0x2e6e638d54d36c7f5394e52deee1fb8c2535864f128cefb80ed64f27078aa1b6));
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
            Proof memory proof, uint[52] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](52);
        
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
