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
        vk.alpha = Pairing.G1Point(uint256(0x2baf1e98b2c21b84949c7a64e4c71db5fb56a99ba3ff3b3c1749fa8e70208436), uint256(0x22e7a17407d4b084063693538c597fd983eb843e045c8bbec939f615aedfc7c3));
        vk.beta = Pairing.G2Point([uint256(0x15a223fd5725ad196b4ce6fcbb5a380c073e0b3d135d152d3249cda8b68003de), uint256(0x09c845d0a37d20e40dbf81b2f796703a63d6a3ae56c9a30b49951696b99e14fa)], [uint256(0x2605d35d36972d14ebe430709d72160bea8b2a1afdc255c72be523bab1f5ed73), uint256(0x06f8103120ff57ac4e13cf4423745dfef3276d247e8c94e162550987b5c7c97b)]);
        vk.gamma = Pairing.G2Point([uint256(0x156c9fd56eeee5410afecbb02825b994d7f4239cb63324c1ba00a2f5866f5eb4), uint256(0x0088e872a7679a928c8fb1903b00040c1b76e75fe18a5333f2e1f3fd1775ebde)], [uint256(0x165805f3e5716d62832d747717a7d8cd950dfd9fea0e804633f86059317c72bf), uint256(0x1fe32b81a5169a91b6b80cdece4a389c45f5d50fdd8a88f3515212cb089d939e)]);
        vk.delta = Pairing.G2Point([uint256(0x1514c58ba59a11f65b3b7b166664c0968c50308e20b2ac989f44dc87e1c0d206), uint256(0x05d4715957a0cc8566516fdecd76ae79bcb91b237ecddbb507ede189d104ca32)], [uint256(0x1367703b4a08b8a570cddc9ede2d00529dcc2d209b308725779e2206d1527b7d), uint256(0x15fb6085ddcdb64cabfdfd091ce4f3f988d2e35e1e8a9ef6ab26b6d36b4b38ee)]);
        vk.gamma_abc = new Pairing.G1Point[](246);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x078900df721e70d3751a0225e9b614b2e949003f7a61c1c7dc73e822858406c1), uint256(0x1af5d7aba52a7a5ea87adefe2bdc23c9d3c84e57539fb2a80ae757ae2f2d441a));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x146126e67645f579bb6b574b40b4ec9840e181f626c19f1c13b4d2509c0cdf5e), uint256(0x18b7f0e4069cd13ef40090207f6bfc2edc13b73250983a729094fceaf51d5342));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x20eedd907aa973ccca01fe2fe2728c198514158d34283efc1c4e33d3ce7136e1), uint256(0x01328e724a9aac6552143e41b0765067d2749524ee042c8c0e768199676971f0));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x28ff05e2961ade87898eff792593972970f6c129f2029948dd646eda087cb68b), uint256(0x1b81173eccb367b0f24e15e0dbb5b8cb18cb2a52b9fb55dbe599b57daba50f2e));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0b7c8ca49b1de142b13969d2ef8f465b38e5b032c54889cd7ae68d8d18993522), uint256(0x1f8ebd7a5cccc2faa6d286feea3120b8a7e3b9a27ede1b648f20592abb820b5b));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x275b950c3a4b545449240459c122daa554ca7597d0f3c9eced66d3e997197b5b), uint256(0x1460503ae6a066c1e25813478051732bdb96647924a9ba44fdeb2fe584e9b7b8));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x19344dab4b411b84e0ee5f4543d14ef426a75eadada79e6396be79ba40a7b1d7), uint256(0x2963e7b5aae64170a8b55928676745ec0b3b19871c173e6957805a371f6c6d15));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x01f125fb80eef520d99b70a993cd3651a70c4c6d478bbf953a9b90fa74d2cb3e), uint256(0x1104ab594eac027af6f9bb0cd3cd7672a6cad03de9cc33e41320d3f213f58ab7));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1b4a8db48789aad367dcdf0b51008dbdd39458fd80a7c1687b5c3de7398a7305), uint256(0x0928273d587a814772f1df6267c40db073a48e5840f53552bdd7f32c5d2cefb7));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x213f795b2466301a42962f66dfb2cd90f957bf099d969ae9aab554e07fb774da), uint256(0x0c4d0856e989025631ec82e34e7d7701e50c032309d291660b761d9dc8c68f4a));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x05dc4cd05bc5f6b940c4596d4f7f97e5dbfa6b32b4f41f1ec5b7828051bd90e9), uint256(0x01ec7f6e6f4ea1401e98953c0f86be4543a1565ceb81187251e2db2fed4460f5));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x00cfe407887e92a8adc4e2bccf03f197146ea293e3aa47a6cf3d75c8b87eebe1), uint256(0x27b72b042d8c9525249a8a63f4ade3674e7ca6ed6b2b205388ca83cfa2417e53));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x083e37213f55d8b9896ae77efab2c3b9d85c7216bdc4621b29797d62f8452cdc), uint256(0x2f4343d9568c3843ac59c71fb5de88d403f81c23e161c2aa6d67e09b3928d677));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x148842f4577faa297af1f0d80425fb81e403506addb88d123905d4c3d29d7ce8), uint256(0x21dd98502cb375a62faa74073e32526df877776cb25a05d1f37a7fabdc4e19f3));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x23b2c88fe5094613210416c2b24062644a680285c27e466bb9b0f6c918226577), uint256(0x2009ccb8cec8a0c78ddb0595a71a856c54b5d3ed4b211705dc9417510622d761));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x0ea8263dc17f84b2670f7adb2daeee6e44210f645efa22b45091509f0774619c), uint256(0x2a4989eb74d9aff9fc264f749947efaf6d987821fe9d97dd676d48c0ceab2931));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2bdac00c53da5558ec4a98120a595635f39faef6aec4060f1df1e82033d7b2a7), uint256(0x27ebf1c5545263fb89930be41f1f348c164b94d1772505d9d4038c446a1befa0));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1b0010228a6f22a0bd669da9495656f04e0e133cb575392d67f46f11cad1be5a), uint256(0x25ac2901893225aff50a1c681cd97748e65dcc1aed9c995e225c5331f18f6cba));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x14def442ec03b52171210527e7d66406f7f50902ac78b17261bb0d8dc8212932), uint256(0x15d0a2a510f71b45e7d7a8d173d49da9023bd10a2d5be3d96c2c2d9ec6521345));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x16f0c57f439c05e3780bd42b9d28fa789cdcad856568fcd5493848e516f6a763), uint256(0x1f339170ccfff97d93cf402279a5a1ad3125c9e7ec0c956c70d48458cada215e));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0bf60cfa9ac6db5df162aed267252ac3e5683784df5f476fd9e0dc1ca235c41b), uint256(0x12c8b10ad2fe39bd7695e688c2ef41c146bb6c2f14e87c028277ac66eb4be3fc));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x07bf6e502968fc6a892b31ec94eb4dd8298f2830e065978f9618dee26a6d2646), uint256(0x131781a4b6905a43db7086306df823daac663df6377712e5a58a63be6f2249ee));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x04d1add96d3313a8563b6310104987f6d8fdad414aba44ff70634dcd5c6f971a), uint256(0x2cc2f7e576e2d80ba96c5ca9b45aecc656b746b9801738e0699b96527666e253));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x20dc78b8176d0fbb3c5c55cba9a7630afb62f8e0fb9125e435cfc6fe909e7ae2), uint256(0x14ff0c0ffd5a472c2752136b40eb727d943534f34602b5f21bae697361817597));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0856336731a43c44159999966f725a583c284805262aacde63739a9375903e16), uint256(0x04f9a2300d69554f4320e4d3242f34211103afafc6cdb182632210b29072e18b));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x0a6470bd14b90e73ba91bd5a5b93435d11a42c5dda4fc1eed70dcba63e971c3a), uint256(0x16c73be3f946511775f389fb39557f41c819a24f7b4d5b662dcdaef0581129b4));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0bc43b385b45c94ef41ff0cdd7400a4cfabbe43dfe19ec6f8a15a7247b26ab51), uint256(0x1290d6c2517e5800c6179dadda731f87f1417659ac740de8319b6367f795d2a8));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2f0098b24a5f8302b5c93adc507175c384d650f1afbdcb52ff23e0802af3b053), uint256(0x069b7c2f59741310164b4a34c842f64c6c0b48a4b67b38a12a8df9dc8a2811c5));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x24a39f2f118b7a9a261ba50b74b37f30f5e61ed7da6a61adde54adc8bd8a1b1c), uint256(0x21dd16f4b4299507bca5a0c9a1adca7ec84e031283719772f470193aebdfbde6));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x06ace28ece984b118c2344fbb1ef8e2e378ab2aee104d7c1fe565e8d7a1a3ab7), uint256(0x2b198cf4e1058fd04b139346671dcf20b47c9ef0e00d79e154ab968e055dc3bd));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x288ba8b37f5e407d22068c351da5a6549ffdef93e695d03b2dd353cf4896a9e0), uint256(0x20f710a1077d0d38319d44eac99ea46339468c35f14ea9074736a7d4926ec2a9));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2546bee7a82a7153099578cc2cf905f5a0a108da79f65be563568c1a2febb37e), uint256(0x2b6c20e3e37c437f0af648652befdb5e2810984050357c1129ea1e8f4439b8b5));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1c9c81570a514fa0543a8fad268ca0967b41d8b5c323c8d504ac3f81a21f42d3), uint256(0x0a3f570ca146219ceda64f3e954fa1b553cc5803d8dbfb7251503bc8a7a0f61f));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x25c9659b5803fb62a407fae862cff52ba35aa98eaa08a9c2cfeaaac3d0ff5056), uint256(0x1e0eba0a41a47dc3e52c16e77c0314e6549510fbece0ef21b816ffec803080a4));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x09fcc5ce2717b1e255c19d318dabc75acd95df190bc1b64fd298820422cd93b4), uint256(0x2f3a903eeef9b9e909aadce69b8ea611e8746148bdc5a4943437528283f1a2a9));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0ea4f7fca67ea41a4ac9be1aa59d87182ddc7ced4fa353db6951579b8b7ef2ae), uint256(0x271a5f60508e040990bcb484f74bfd93351afffa51804e76f00508d8d83b8aec));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x213df63c6c8531bd6a808b71445b151e5ea05934dcc87be79e81a27272fe0796), uint256(0x09ff7012e7dd7d07bf65f7d44d648f570d162691515381d8a19a9e51ccd8fff9));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x01f18f4e1bd2093ba0a6e16a078a2edc74a4702554304e642d8731ebecc2a643), uint256(0x1ff5751350eca0e94806770583ba7f4ccfaa244d2d2ac3acec36b02b8c523d72));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0f4a89bf1a23372856919edd5695893ec9390a325e29e7a4f3e76f6b534298ee), uint256(0x0a546bed818437098762ae317e5d5366b79cf37960e72925e44bb12fc76b35b7));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x2a6ef6a3640cd45f31c40eacb3534d183d0b890e5a3d1036a4d84945676f51ba), uint256(0x0af9b210caa39688ad7f54ed425b21d374a6876860e4ee21ceb8f70dfbd96216));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x04ac6f6af2a973aa5075d3bcfba8ef69c6b0d92b803a1dfcab78b6b6ce16b719), uint256(0x275258bc3f9d8cca43624a2fed5a7980ae60253cb19d86108a1d18ec6c177d90));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x258c8d91a1261d7e61c56caba8c90cc21e338c4ebeba88b896754128c65f70c9), uint256(0x08a80340e0c3ad7348fbe64cd319b5650798d11b81a8ac3c6e4c55021276fc60));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x3019b9c5d309c01556ce8cb52b7d0b5e759134948076302bc3867f0704aaf25c), uint256(0x10b69a16fe9cfe02e64f2c7da04b7d9bc3d39645732151a0177ea50fe12879cd));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x2689dfa30d7930c31843c93400f952c36850f84c72f9a5eec5642a2a93ca736e), uint256(0x093eb75a5e77704967b2fa101fa2879eb338418f614d476b62a17998c474b957));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x1048db04a71c8278cea2a0e7c7166790f2d832b83ae4717df052ea3ad243ded5), uint256(0x0897ce599bb7ec5bbbdf8f4558170ce4f36b8ed88e17702a2ec49939886f2d05));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x090dcb3a894bddf898689cfc80728d5705895085ee329c1f730c819cb4f7ffd6), uint256(0x2410fa53e878a37ce53770e9166b296f12fc4e3b049a321e2ca2e70d7a1b769c));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x12076f848bc723f187c6f3a1c5ad3fe54f4631d80b9a8b568e5d6fd144b8bc89), uint256(0x26fdfcf1216074dfdef70e4ff8d3dfcc647ef07a12118a3e2d5b50e9c57944c6));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x22121105829ffb556600913d422ba281165c71020faca73e6eb48386d3a28f88), uint256(0x0b2c18052616cfce3db008343af12431efa982a5df58d401705acdb027813080));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x2bfe6682cb170add2538484c5ce12cdd67cfaa4ca5d47e7b3b28e7f2805930ef), uint256(0x220fae9e3588154fa6c32694644a5d77da148c4b811af12caccd7c43a9315954));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x08caaa0a663f37e88800fffda3efcd3132e0899c4a03030c573327c50db11f55), uint256(0x25b2f170df5b46fe3f24251621ee7a7d7187590a374d7e595482c4dad2c32861));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x2d64307165ab8dfba6e9cee00f8465b2af17f4947ef40a8d8782e1b06e0b5e44), uint256(0x25ff6d763c3436bb67b3f6fe5deaf49b74554267133316bca95903344c093f1a));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x294b95e98a83b4f078ebd9dde83739c6f0edba1ac802e09a0dc8510620c8ed1f), uint256(0x2d8d78b1fc05fbe5b166c4755a87e532ba8ee409436e43baa5ab1bf774ff1892));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x264084d08478986d88d8195c43711aeec48591cc8876477324418d2d1516e029), uint256(0x11c1d8b1121b843f89830447a08236a72c647add3035effc24c3b5f50b4fbd12));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x219313822ecd4ad3e82fb0b037bf575ea5947f3fb7b93f0f2f005c1c0c92b21e), uint256(0x29e3da10a57a87433fe1946e93bf0293987e3d389be4b7d3c3ff97e1629f12e3));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x103074e29170679d196013fd642c3736e966e4ce54e33f54ad1d0d81d221f026), uint256(0x0a41fce54903bb7a40b577095289319ea951c5635a65a8020cfae21e6dd86d13));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x00b64edfc94994a32ea0395e2c60ed302b5871e74cf8d813791e0a25a4693100), uint256(0x083cb70718e8eb350847e9f0ed794f7bbc0c72f63bd57d5f7528f266dc5d336a));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x06ec7fa7bcc12c48b6c86c701181928d24b093348f506ccf3b918267ca86f5b2), uint256(0x24108c4748fbcc7aebbff2a3a8e6cf349709040db0b4ab7a8e5ffceb95f0bf34));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x05ff890d921d7149bc941a34384ed888eba317cba89c198a362d39fcfa5e9db1), uint256(0x07ba44843aeda5f3a1ff19cbce65784af3fdbd6c7b1635389ade893b0349f52d));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x1412d174f875bee900f07e3f29a645e052f3d3eae0948bee031b6e981366809c), uint256(0x080311bb2552ecc2a58cc3fb4a5515317e08feaf2450d245224020c29086c2f0));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x0b677c2cd3049dbdd724511a5e185d54e53b162c4c78490fe8830deb29000c39), uint256(0x1619ff49f8e0998a35d874f7dc47f208d46e3df208408ea0c759824ea6824394));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x128a6de93668753508ca0036f47f6d0910446d917bd159eb6ed6703308053005), uint256(0x15747d33f39708c588d0d78561f3608b4356b95cbe6cbdb6e12442d817dde65d));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x015fb8d9e34ac0d70dc3fd7d47005aab855a7ea31bebbe5cc00ce168564219f6), uint256(0x1ab86e4d3a5b1be098d071c53c1cf3503d2f542697824dfb4a17745b2ac01d20));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x0dc07f0bf2d59b6aacb20957e1930cd3d873cc1761bf757c2e9237d1ca316a50), uint256(0x024bc0753ae419a6f9e9db8491ce522793566557f498920f3776573c7956eeb4));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x27fd1a494e94b8cfb1685e40a1dbba3c2c6edbb61cb2bf704f56a7a45b33a2a7), uint256(0x0dded9cf6874fb1dad1cf7b1c697ad1dd5e1fcce2b367e780ed6445bd22a4f59));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x03eafb47a142c07daf6fd80bcde4aac12906c67eef99873c3f56a8014eb7fc42), uint256(0x1ee7f3754d8c4a01eb2d3618a44816ecc19f1b91548ac6f40f59ad572bd6c333));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x1794adccdfd17ad53ec9afbae6523633c19c74b83c156f3d9c062d5d60597788), uint256(0x2f9de45e3da7dfcaf9d55c2f4df130fd2472ede9654da588ba766fa1172a879a));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x2d1cda1a3a09fff10bdb0da00fe90bcd95149a9b69f922d18cbcffbee24694f6), uint256(0x1ac63b4d672943e375478b8c8ddeffc5b4b94d420df5674d293f9695ad1b4685));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x18b3cbd8814753a35257eaf01c474e0c9679591951b63fab3ccd14416f013bc3), uint256(0x2b1fd9a4c16644d252050f169ebcefd41a5d3aa43ed81dd84dbad4284b7fa205));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x2d8d8720390e9426846b71406f1b205d74f4b810369ca6f6d3670778cf372266), uint256(0x18fc532a28584007e426e76fb7f310965218ed52965b2673a54d1a7b1e5a5aef));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x1c11b2b335d47ffe8404bfba8ae8493398239d90610daf025cd497be85846f8d), uint256(0x2a34318e64eef6374f3794568719aa2ddbbe2ab09c5ca000fdb41940f60eaaa3));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x069c72b83101bf17b8ccbc0352c8c14bef12c275700f28cd6efcb236de29c107), uint256(0x2b70795a4b7fb138d4ce50d2b663179d3121c799cac3ae920958722455004a67));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x10b72c3a532a8248dc85b01034a1fab0f122e8b66aff17492b5fc56712fdf82f), uint256(0x0dbd008962ed389803aacb698d41e843e24bf049d2a0cb8271df073617770492));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x1c369305fdee36cb0176105daf1d7c7cc44a76f9aacd3cd7e75454a4dbcbc8ac), uint256(0x21e24d52fdea358da149af156b53ed8e4856be82cf5c3841982031a3dba09421));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x1a9cc7f699760bbeb26fc6c35ecfa42b46108a955071e04026efdb55f0dd16db), uint256(0x0da93a4c28207c4971309d905aeb26b8c0b3bcc64c94fb065745ee9385aa0ee0));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x189da259d1549c6232f36792ca9a4213d1691b3781ac75ffeec88a5ba6c922c1), uint256(0x1f4bfc7c4d13e723262e75646fb1abcc749a23d704052b55f160e22b71667f57));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x236aa60594e6f224da58c51a2fe3bc965ae5b31d99abb31adf4c8a8d703140ba), uint256(0x09ba798c324d543c9c61ca9d1f9689991e53ebb4d12208fa8d5ff778a964573c));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x2970f136f59c8a0d96f7b10c5aa9c12601682adb8fc8900d0c93f9bdb47a770e), uint256(0x0da274dbc0ef859f5e6a44104baf7cfc12ccc0d9412556d1ac24b6b1c5e1940b));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x14d88bb615ad75ca6c97da75b66a4f3c7225b268b2239455d5e42a0303567c14), uint256(0x17171d5d9a6fdec98eb3dbdc19776659b81ba891247b9cce53264d9e46b27664));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x1bfc48f8c94bfe97d2f05288d88544f875dd8f2484c668ce1b1c0a6e6ed7d532), uint256(0x021478942b1af9664647cc3fa01fb45a0380ad2f71aa933f73c537064d012d88));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x0c955f2f29e2a4fe40b5621d305d0358ff311b8e55452f6d5e27fba85d9504ac), uint256(0x1ebfe3c04e9347d42d1e4ce19873a5224c71f0afe8efb04b290edb0472c089be));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x22f1557a4fcd50bffd89fa92c31536ef8491b230c9569a175d5744b15b70a6d4), uint256(0x0533b46e41a49378998261917c700a9d3ecd510758bc81260d4c5071628c478f));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x22c80a1c5d8e42fcb3a0286f5366281651e1abc5420f72754c9296895adf016e), uint256(0x24d803009792cc3ed37add6279e8ac0cd1cf0cc3525e1addcd3b6420f2089282));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x2fbfd485bee5c6237c9da3ddeacbbdeacf5585479e2b4dbef0efcdfb743af408), uint256(0x174fcc1ac325d158710c285394850e610a15c4648295b793a20b7ca4e8bda331));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x2278b28843eb55389e1795024fef16648524b5f75cb855757eb8486daf56a634), uint256(0x144bf3ab4286cce8e3afe645f94fba595eaf6c775c993bd860094fb62fe79709));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x2d32a954d354f7b17687aa4d58ab8c3202edf0f995dae23bd23a1b1dc2935ea1), uint256(0x0af025ac708157ef09690821878f0534e5f7c7e9a39153b67e59cb3d15fdf916));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x09899bc7a39c21d018480b9c45da59afb51fa992cb79244188e9699e5e7d8fbd), uint256(0x261bb8fb4bcf70c4bca65de1164334e926fd56533592ca7d5cb2f73e55ffcf68));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x03addeaf5d512e924c06dd0e281e45b7d744bdd8c9fa0ce7f58c6d2f8e52d3ac), uint256(0x0e394c562577ef5e27ff1fb52241031c5ec517e266ebdc73d1900e7a03031fd7));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x2bb1438cbf471dfe5fca9bfa4b592ab797c88c69285f32a82c2f487f8a286dce), uint256(0x29da583d61162f288d16a9c14b93d3c6a325dfbce89298110c30398026a8cdce));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x1e22d836300464f096ba48c518ae4076d60c827952a1b86e63eb6c98d46fb88f), uint256(0x1d90137690245fc7961f47582922e5c4db6826347d02c86ce133b885afb6f567));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x06882ca47aebcb354c9bf44d1bec0f944dc7939dd1481e8572ba3fd785d4c9f8), uint256(0x2a14d6f5f349a6aa284fb028335cedc9de28a3039a04c483286b6e756ea2616f));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x06f90b26dcf9c5c079eca6e2ea9487b103d92645396f177c3bd2ada0c522c9c5), uint256(0x159cd5e83973e02afa156ca79db16e62c514a0440487d138119ecaecb4811d28));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x16d99ed63cc9630a8208aa745532b8cae8606be8e008bf9bb10a238897f64417), uint256(0x04a5078d9cb6cf959c24647172c33c39b4783920c6072a8ace4e78e7b3c40269));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x0034e9e9079f061ee32ed526c83747021aaf8442221d8daaebbf5c1b7a298305), uint256(0x12179e0b72ac17e216d8f49a4987b03f8e67a59cc2d97bcbbea648e55d0ed10e));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x09ec0551563044163be975282ba58d95a7700557bb96938dbeddfc463df47878), uint256(0x02e7a872be57aadf8087281ef82fec9aa7dd551c75723236c900947d07c52feb));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x20e13226d6295d1e550e51efe348b5a7ef5dff5da9aa8e8bcab7bb00ee0d27d7), uint256(0x1353d2b6b7c4aa1401a844d67060e92b0e2e729d0052bbf805d4fa2840abf794));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x04bd940bf59cedcde9f6cabe3bd399ce989c545adea36cbed553769a64a17b25), uint256(0x0ba875d8d70ac20b4cc1efa5afe4893a024abcb56e55f7a86c85b50dd0833698));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x1e840bf5538935f25f151e570f281adfe8c4e8aaff34386fda83d3f99f88e697), uint256(0x107bd85905740f72d4193c5c8510bb971e02b1b6858a899ae6eb54ee047e18f2));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x09aaff79d23d06a88bf82680bb79df7fd5f2c8c0a878d077d4a242b68ec8ad46), uint256(0x27c975710f4ff66f22732267d568aa460353a45c8e7f1d1e8ae6f69d27655b24));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x1ae172e91431b8f5d8202bec06ea4769a77ef1f91b5ce8d80ffa2271e69dec9f), uint256(0x2dd2ae85d4aac8bff72cfe96a3d368334dd5b1c30c3293d1fd1e3f21426c288d));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x0a342e4edf1a98daf88ca0bf5fe5f5d0682780b07d026c867492d17e8df3ddd7), uint256(0x2abb5fef6400bf1bc9a3c6bb381255aec0996d9c3bd0d77b5fa6e15243028cae));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x069e1055b7fa0c22829a68da7e685a39713ee328a323a47ef481ae4aa3f00e86), uint256(0x08269f1ab82476cd9d73c9be613ae27d89564200b32588e341fff59d7e2f31f2));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x173532ccff1895a9837dd4d4dc46a1cf1b1b7f583c4574474ebba22bba01579b), uint256(0x28be87519d46c9db60ed43a144553997053e62df3d33b1d306be760b466ebc2e));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x0ce3faff463526b4043f9e821f32e4d6bf767958a26a5741f1fdfb8d283adad2), uint256(0x296b7ebc63d39265d687868abfd3b57810cf8c57d01f9c1df8dffba663f74e57));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x0aa378c3ae6adde39dc3370d1636a5783fc43e3e96ef55fba45d27b7a8e7bd4f), uint256(0x1921aa8caf38acee76e1681221ca06a05c2a0f797fa4b0d705e11c4e7fe57286));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x292151dc5b647b33e2a4e89dace07e15e50932b4245e24033fb1acce1045c2a9), uint256(0x1202dd7e9cc848a53de1200d26e089203809b1f766d64149f908b55a1fb7d6be));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x2f8852bfa090ddb3ee1ef6440b78fdb76a494fd660fedf1da74bd55f3ab78f43), uint256(0x26dc62d1a367e32db766a1baf856a7ead6a7531019d7ee2921e0262ccfc3aaac));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x15bea737e3664a07019fce035cb10a2383384d06160df450e810e4050fe65786), uint256(0x10c9faf14e061592ebf4e171c6170e9aac47c7188c0607e2504dca8eb40a507b));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x13d7f76e41e693645532dfa8126b7d7ea728e0a7e51f7e6da291fd26a9c35273), uint256(0x2704160f8cc5fc2fa31e5f049c41e9396b2810a3009aceef2d9cc2ca3bc69734));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x1bfcdf8de90cbe1c51f9ef080992fd4262d94e1c80be837446afae71593e8126), uint256(0x272fcda72884143cdc982537d02f355e7767c04d6bd8625abeaa74fafec5bdde));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x1556f0b19bf3f295697c7c96772625bc27020b60350f3b581a48e1bcd41dc857), uint256(0x080c8fe1fafd7fed97529326f98cfb43a0173489a03f3847d9324cc1876e8b87));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x2bb2ebc62e26c0d27395334ae6598e5ac0c55df7445214e931a5d8c330a930db), uint256(0x134d019d7cbbad447d32e2f2890c5016935c368121b24648059a75e7b03259d2));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x266993931f30cbafa7215e3febb0bd77bbe1d077b0890b58de8223216cb395ae), uint256(0x1705e58bdda4d14312b99a6e17b79b23af79116d3485f37d84051cadb8b63b54));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x067de386e91eb4015a6e72e92f8aa121eaa22f3bff0a7321264fc4319dd99f9f), uint256(0x111609f0fe4c292553ff37a725895c9edbc55a4a9d6c6e7254440bff7fcf3b21));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x1de4cc363ead98acc04b3ab78e455dd5f25e631c19bdee68b00d5f886cea1769), uint256(0x18ae2c56c0b5b27c0181a6a88941d119536dc4d464e5b3933d1cc6353cc0a6f1));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x09edf3792a4e375363d6e407b562231771b456fa8b2fef56b74e6df6a78ba6a8), uint256(0x088feb324fe49a6ffb1d244ecc452bde67e1aafe5982a22a7fd749902c44ba34));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x0c7f1e14e851a9627f705c2032ff869796f44d34518f9b3be970ccd4cfb9eaa0), uint256(0x1ad3637209c58b92a4e1f14b387adf1cfde0da5e28703e3565d3a799d347ab85));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x1a51a9969d75831b96ec7ee4cc7ff6b8cf97a517ffc1defc6048e2e9909890b0), uint256(0x2eb2db6654dd35f200b8e66473ca3a9e98735b29e125d643cdafdfe1aa7e8468));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x289f3cd7948f91107e68c454032e8ab24ca1d5b653429c77356bc7f31a272a4b), uint256(0x0ec519344fa2ca5f9405c16df13cd853577a0721e3aaf8c0c1c8977cc2681621));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x185fb862e21cf937b3d1758f42cb11a32b7a577e552d7d1156e4d08916457818), uint256(0x271d8834719209b2e87635c4c45a4748215486391644426caf1f64c6a9c45d02));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x197bd772fd8608a9c2e581c2bba562b8248f696479e208cd5b680f9ee04b16f5), uint256(0x13d156e8a49f5fb04706249c79b2f14e042687f2ca1bb8bd7c2b2bdeafc33e3e));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x3047704788b9c1944f151d102be91138e201614f70913e18a58e5615bf5df221), uint256(0x2f75a916419611a6d2841762348b7707e055c79bd22670d7fb472e1c4da980a7));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x13bf9f4fdbd925f05cab9ad9957ed2a5a45172e32cd39712fc5b9176d9a377e5), uint256(0x00478ca99d3d8eb9f34c7e80d03952733cafb656d1adf5082b88963dbce15427));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x0c85974c0224a061f24eb1713532e220e0db5fa4c6b24e0919d1ea8397e5e7d0), uint256(0x2525dab9f923b205dc371fa1a74ca1956652a1de9caca3d5f0ae86e5391b77f0));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x1977e425ff02c3a1a27059c7c9060ac6e34dbb1dabcb42c3adfec44a673c696d), uint256(0x2523097d3e383419bd16d7c6afab265d81041f65fd7afa819a380eced99da27c));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x0852270ab6df10d739e197239a3b81ac69381e9917c5e2c8d553e35a8520849a), uint256(0x16367345952e81d1d91a448bae38fc2952a2e7c4a2dbae9d910a9bcf750bc4d0));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x1d18ba53cbaa762a4aa9f07225f9b8d2f8a4c572ebe5d7266446c7b06d5cd8da), uint256(0x0b547baa66e43ce6f0b4b3d2123b780d28c092e23fefe2ad3fca7cf08c7914b4));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x16c0cd0ed969fd8d1512c12d0362a778569a4a6540e4f88c4a29192b4270937f), uint256(0x2d17be3aa2184075cea3063369b32bf983f1ca06af638dced254b5b259a860b7));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x0d0ac6ee1c4448279bf564dbe5b3e0109898e42ccf76d2e394434c2abaaa6871), uint256(0x2661867225c166617398a610841029c0aa84c490401d42a17c489cc3118f0ca6));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x1224e330ef92ebc45bbea0d4da05091e675dc2f055876634842c307f00047896), uint256(0x0a6542959ce77b9ad3d8199d0ab1bae929ccf1e26a6f9ccdffa3f7797f593d99));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x059d50eebce43e84a5ddc181ceee2135a7ca531bf589cc26e219b3d37630e16b), uint256(0x12d96fdd92bfd10ad1b96ea24ec2499c4bd8cb8ad81253fc198b2c8bc2f95019));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x1b1ccbce5ff3208c8dcaa9452ed3ab3a97f255842f2a68bc808b3ce3a634c62d), uint256(0x23af0f951e01d3ac3e29f0d278bc1fb2fc288b6834b9031b0ab9a01c8b45c5b4));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x0599bcda32148794aba6b0953dc6b0bb7af2d84d65d984b0a20ed25d3bb9d0c8), uint256(0x23e1eca909508afc479144f2ea94d0ab5da6a6e629b9a7a58af8d76b9532ce6b));
        vk.gamma_abc[132] = Pairing.G1Point(uint256(0x2e07ba3dbc903c66f61c24ee6bb852e2272bf5e7882dc0455ea159db602902a1), uint256(0x1182b98b5ec299c2332f8e4b5034eb7170b7c6960ccd79c1ef20bc85600171b0));
        vk.gamma_abc[133] = Pairing.G1Point(uint256(0x06ceea57fcf078e2f9dccea36af42d1fd49d48d1412fe47cd2938966f798f9f7), uint256(0x067a14f27cdf274db9c53001b370e766d6be2b24ef6f0257209581b4eec1c496));
        vk.gamma_abc[134] = Pairing.G1Point(uint256(0x2ab4c70ec17f92d3102d7549f29e81da110b2a0ac7a3ba68bd22fff8fd18c765), uint256(0x175700cbcb07b1c5eca85ecbea343bc30e82ff014ecf14b868f64f40628643a8));
        vk.gamma_abc[135] = Pairing.G1Point(uint256(0x01fcba686ff86db92c624b6240c26d94fc23ae5b655ad5f2e6f5a8565525d879), uint256(0x1cc73165173f4dd425a49ee348c6ad954f81180a6faa8f98f5e0a53874be2087));
        vk.gamma_abc[136] = Pairing.G1Point(uint256(0x1a53e5f5dd5e4d47fddca4f93104ab025fb6e60263860bbd825279422fe4c1b1), uint256(0x01e00306bd2a9acd443fa21d41f612538ba5c2eb5ffe29e27b2e100f3357c0c9));
        vk.gamma_abc[137] = Pairing.G1Point(uint256(0x0a87d93079715f58723b910a049b8b2e35b149a8486c6b202627eece7a16473c), uint256(0x12c984e63c297a30a3d6eeaa3faaa8ca86324f79f4406d1086f68490634d9bd2));
        vk.gamma_abc[138] = Pairing.G1Point(uint256(0x19ac9d930d9d1e2cfbc61b52bc73df57819d4bcb3e20cb4d4353f6f5eaff1c4c), uint256(0x07b42b8add40196a6906b46744a9c9b358d49eee28d0cb54ed9395ce6c9c436d));
        vk.gamma_abc[139] = Pairing.G1Point(uint256(0x30579db8d8d18f4e0af89f5212983ca2f418fc500348b1d05930c539e1656d7e), uint256(0x067732ae7eb44e85edf1c02f75cac56e3f84bde624f7e9b8cd833852026ebe5d));
        vk.gamma_abc[140] = Pairing.G1Point(uint256(0x220b4b798c301ff298808e7113ca5eec723ad0ff15ae98284b080be02ef40e5f), uint256(0x2aec183bf341930cffc0afc6acce25373f05cb34fc2ee070e314005d06ff766d));
        vk.gamma_abc[141] = Pairing.G1Point(uint256(0x19e118864cb348b3e4b8e81e31af54e5522633e0d194025b78064c10b00fe5ad), uint256(0x0d7ae30ced0266d5392e5fddd6b8111123c855107ce6d263066aba535fa1ef7a));
        vk.gamma_abc[142] = Pairing.G1Point(uint256(0x1968635669dd556eecb06153ee40718662efa6c80cfcade3719d3a6376369ad1), uint256(0x293927536db781805a0a2d7c5dfb8a6d3757749b8afc2f8e6b228983be18dbe5));
        vk.gamma_abc[143] = Pairing.G1Point(uint256(0x15727faf377cf4d31c14cc4b2dafd461ee85dcc49cdbe761b48e6c06958d4d68), uint256(0x12eff6ffcb0a9e1534b2e3447b03d16113f5ff33accf50b40880f13014e95dc8));
        vk.gamma_abc[144] = Pairing.G1Point(uint256(0x2d57c7ff2b99c067d03c5066ef7ce692f82079b44f4feda7399fe6e207f271aa), uint256(0x1fd19b1072ee4d4ef30edfd28bb0933fe12f3d7271fc5e0a9c679c48df4d5fc5));
        vk.gamma_abc[145] = Pairing.G1Point(uint256(0x1fe449adf4e03569efbc9bfa0f62e5e160f43d76d803867799c20fa954b9bb3b), uint256(0x225c9b32bbe074ec43712fd48d8b6bba2caec8b9323b8e206a960e3d5d81d7b2));
        vk.gamma_abc[146] = Pairing.G1Point(uint256(0x08fc0bdcbbd5595d72ad256e63cfd03a25219ebd0fe588ee201c973c3041ae09), uint256(0x287962f76f40d7a7503fa3550b542b6f6e7f9796ed335f2945aef832b1a648b6));
        vk.gamma_abc[147] = Pairing.G1Point(uint256(0x1713d0cd177e6c62582ee76c9b6c7d26b538bcfc2822b82b7f64bffc04376625), uint256(0x2e9c1b097e3dd70f9fe59e33b005de9f189d3067091ee54f01a03dc248b3475d));
        vk.gamma_abc[148] = Pairing.G1Point(uint256(0x2b2c6f6060693a6285d1bbe214823a23c5ea9e89701a41813cc4044f54aabd4c), uint256(0x142c09d8b36ff5439cbb750087ae5514373dd104469e30572c05e49a0852997d));
        vk.gamma_abc[149] = Pairing.G1Point(uint256(0x06528ab709eb5c6fe85ae762f7b5d37a633148a85d884cf793ca77d7c85a1f20), uint256(0x20af70891b2a817e2f8fcfc3ff6d8a7a039dd32c00433e97a5aaa6c31852d02b));
        vk.gamma_abc[150] = Pairing.G1Point(uint256(0x22a6d07082f5d772665507250fa9901a8a8164e985fb8492cc30179a5ce27c34), uint256(0x2f7d2312deb2f0ab40e8d831abde013da0b58b1a71990d93b963c11b1857dbbc));
        vk.gamma_abc[151] = Pairing.G1Point(uint256(0x02a96bc4b533577c3e0e9b831ed00e34c9437976b0a74f4d1bcedbf3f97e4b4c), uint256(0x2ab3fb1cc6209e0ed51bb6b679d18bc0465220015507b71f25306e0931db97b2));
        vk.gamma_abc[152] = Pairing.G1Point(uint256(0x2148795340d6776c62991fd461eb113b39cea2630d0d5887f6d1860c5c0d87ad), uint256(0x29a3bf27383cd14e169d1c69e7b89052e409b05cf1c837e19bcd337f6a864e70));
        vk.gamma_abc[153] = Pairing.G1Point(uint256(0x0b945367b4cee92a163f93a88daca3bbf2983614b230c2ac5d82942fdf714784), uint256(0x07d7a53884f60ccdcb640babe75f3df1b3c38a238fb76f53b5c3efe17f8c80fc));
        vk.gamma_abc[154] = Pairing.G1Point(uint256(0x274890e5d0856ffc713cafed9819a5973af6096c5eb81afc148fa03f56ed8131), uint256(0x049b388311b25153a9960872c1a9ba90c7ec237a1da557462d85d1e8288af764));
        vk.gamma_abc[155] = Pairing.G1Point(uint256(0x1cf3cd323fc9df50c9cf2b68e9a353c04f07192d658163b289910961da56601c), uint256(0x124ed1fa59f86f318d13a9263802216e382683968117230f4d60f2cba62b4d5f));
        vk.gamma_abc[156] = Pairing.G1Point(uint256(0x02488fb0df39bbc244bc290ec5940ee80e9ea544748c55f0a66ca505f37ab9e9), uint256(0x041916b31267998a3d8ac189107eadff26bb4a83ea28d995c46fb6780df61624));
        vk.gamma_abc[157] = Pairing.G1Point(uint256(0x2ba5626a7c3ce047950fcd4e7fe2431305dd712672ad282044258ee1fdb4aeed), uint256(0x17cf5e57f4a1c34f7d6cf994d52e68f554c8d6e25ee066887bb33aa44b99982e));
        vk.gamma_abc[158] = Pairing.G1Point(uint256(0x2b25bce7fb98c40e75f6d44d67cbb5e7f1b4ed51bb21fec8e8dd8be75294e07e), uint256(0x248c2138dd7ccc5684d6a7f0ee149ac8d9c7a91846d4d4094cc8be1041513e14));
        vk.gamma_abc[159] = Pairing.G1Point(uint256(0x03c0812deb6157a06feaa18b3d8e4e95b7dc43c6ad41db15f7afe3bc7feef43b), uint256(0x0e38aa0b7057257a7445d9367cdf74397fab4a8251ad683cd74ecaf504d9f1c9));
        vk.gamma_abc[160] = Pairing.G1Point(uint256(0x0f1961b672dc1f4d8aea1b71fc4df862ba775b727a46403e2f96970d9725fff7), uint256(0x1278873a73a65dace5c9ae1230543a34ff912340d8624e7a63870a071215ed4f));
        vk.gamma_abc[161] = Pairing.G1Point(uint256(0x292d44a7f23500f02d3d1d95da853b25623c8ca4f62cac2595cb9a9552c487d1), uint256(0x01fe41d26b910e871900b158b4636699a86ce8abba052db73192c7d9e1d402f6));
        vk.gamma_abc[162] = Pairing.G1Point(uint256(0x13e935e2bff3bca4a1a7cca811bd561e7414f73cebeccc3539374834fff3d588), uint256(0x01067f09521c2353cb6ee1be7b58c68d78502d69e9137121379fa00efc7d62a6));
        vk.gamma_abc[163] = Pairing.G1Point(uint256(0x2e5ccf78e04798536a779e9fe7b89d92c00081a0a3921736496f7e5e25c25338), uint256(0x3036a54efda0727ddd2ac31cbfab23a1991f90eca4643d3cc61f65af8d4c05fe));
        vk.gamma_abc[164] = Pairing.G1Point(uint256(0x134970ed1ac425ff5d32c051bf01457d745e3658439f033cde28a5ff06a3853a), uint256(0x14e513cc92c034122930a5b4fefd75b00946c2dc5bda87ab8a78663fadff154a));
        vk.gamma_abc[165] = Pairing.G1Point(uint256(0x29956dc13becffb5406d9715fb7f5d2818571b040376794b3036f3679d9a1613), uint256(0x07d3f47166dc45071b39147e080a602f262b09e83e09bb7a4a53d5df69a460eb));
        vk.gamma_abc[166] = Pairing.G1Point(uint256(0x3054bb8910be7739993f19db1b21e5db8f2a19b596f1ef00b0ad6e58884655bd), uint256(0x268d509495d5a32ddc2eedaf0799f781beb571bc8b2bf6341a93462344f2a021));
        vk.gamma_abc[167] = Pairing.G1Point(uint256(0x1a388886be0ef3517c15e80ce450a4359ebdbd6276025f86cef7a9958d9bd844), uint256(0x185329c32abb95d0eab964799aedab358cd62a11b35d8d562d8c12a089f3a5a8));
        vk.gamma_abc[168] = Pairing.G1Point(uint256(0x28e1a7c2f452718a48ecd235fb3acbdf874aa1dc64c85d9f9359cc54b362d6d5), uint256(0x134048694d2ab33d802b5b2b6e110036f980c93c503c7ad710663ecb1f7c1eff));
        vk.gamma_abc[169] = Pairing.G1Point(uint256(0x2330e8c760d591c06010fad1a437513ca9d989a16cf0cc9f0c76dcf69651de1e), uint256(0x289dd1c7f778b480539e4ddd93c1094f5c475bd2b85001c3d9cf12f2d185703e));
        vk.gamma_abc[170] = Pairing.G1Point(uint256(0x01f0d88c401a566f3200ddf28543e9d26e96aa8cb50b5b95c8371812a77e14d9), uint256(0x2a5b58ab33701857ea01ae1931274af9f9f737af4494b83695d454e8a65a0644));
        vk.gamma_abc[171] = Pairing.G1Point(uint256(0x0dce372995ff0cd0d97ca7934f9b9fa65ee123f0e114272668820938c212af60), uint256(0x102d43d561709968aa02021c84aa05ea609a6d5c431870c21d12a31310cf3663));
        vk.gamma_abc[172] = Pairing.G1Point(uint256(0x02fe0905ca3a9fb6be66dd1ff2162e9c0592beb44528fc4075041e8d357f8b4b), uint256(0x0e227e1dc7d162dd916b233839b9df1067048fd62cf4a2e232750dae806aa0c2));
        vk.gamma_abc[173] = Pairing.G1Point(uint256(0x2c887d75e68ab14261c74e50f0e925a863c4bb8043f9ff3e76b8d83d6facfbb2), uint256(0x28b908d586ef4c082cfd51b4c8b1918adf5d6a7b7e3f10945ac7068b421da51c));
        vk.gamma_abc[174] = Pairing.G1Point(uint256(0x1c58edab7b2f5f0598043392bd0743fab501c9fa116f730a081022201e159b83), uint256(0x2dd8c84585b860800193208834b38336219f4e738433f07d811bb44b444995fd));
        vk.gamma_abc[175] = Pairing.G1Point(uint256(0x23be4c31804085d199eb75118c589755f0e609c2219f4fe6fdbfcc03cf097184), uint256(0x123a950dc848adabb426f5c4a1d230a9cdfb5c25d016016b954727e8d64d4c71));
        vk.gamma_abc[176] = Pairing.G1Point(uint256(0x1150931a1e44d64eb91f804eeaeb173dc21fad3a90291e0b2809fa135ef791ac), uint256(0x1256c841741c2d3645ca1786e463ac12aa6093e61c6811bf133e1c278e037e53));
        vk.gamma_abc[177] = Pairing.G1Point(uint256(0x29fd9f323e2f95b894ded155fe0670c8b4f82201994de2aab96fd7b8f0b7b7bf), uint256(0x133b0c3b11110cb66274738e4b1d5465bb6a8ff7acec1843757e09824e3ae639));
        vk.gamma_abc[178] = Pairing.G1Point(uint256(0x2a17e6dfbedbef215fee22d2514f698a645c578c82ab14a3baffeaab8ab9d24e), uint256(0x26d1a7b60fb29e8d127f270d64bac715027528b6c346014f03b2f96fe3ce0a18));
        vk.gamma_abc[179] = Pairing.G1Point(uint256(0x019751989e11fafeb2ac10c7c8f45642ad6783ee64bb141891afb3a0590747dc), uint256(0x104854a30ab23f0ac2cf0e493253954d169b42a3b32b742528686772ec2b1d15));
        vk.gamma_abc[180] = Pairing.G1Point(uint256(0x07e24ae0cd9f99180c78f33d1813103925dd883894f69ec060c954601c0affab), uint256(0x068db5869c62bbd2ad632bd785ce9cd80245f784ca6be05881f38b37e7f74588));
        vk.gamma_abc[181] = Pairing.G1Point(uint256(0x0d010a5731628b5adf7bca600a2772eeb7637ec0613c844c6ed6ed107603446c), uint256(0x0f84f558a4f243033b02bfde77e67e27bc5d890889fc57b1f0ff8815377b05a4));
        vk.gamma_abc[182] = Pairing.G1Point(uint256(0x0af3240bbb7c7dd437dcffbe85f3c31fc46f639bb167e872306f732c2b963459), uint256(0x0ab9ae1acd44e58e5e50a8229109ea90498a5833c16d3b465390d5bd5a14cea9));
        vk.gamma_abc[183] = Pairing.G1Point(uint256(0x15587bf392ccca6649f9b4cb9db14a492de025e92183471fb1cabdd57db2b8c5), uint256(0x0ddf715e82e6b9328d729739c835bd02bd94b3efab8eaeb9d2c0f064cb8f2086));
        vk.gamma_abc[184] = Pairing.G1Point(uint256(0x0d57c9a1030ad5fc6cd597680712e165813593b9d7b4241f38ea8542f5d7de66), uint256(0x1aeae40c94c4fbebc505d45c7e7fd517be8efb25692825f15e43592cd432be54));
        vk.gamma_abc[185] = Pairing.G1Point(uint256(0x0ad815c7effaf7cc0dc3d4f8272496968917158ffe80cd0686621f13e33154a6), uint256(0x1b724fe70ae5ea0c150b46353b4923c951f2b09cb1a5d61d866a65d3a50c1982));
        vk.gamma_abc[186] = Pairing.G1Point(uint256(0x13d75a27f4b1932b5f8023dd715bf59f1ecc8438196f0da582975f2e43852add), uint256(0x2ce705e4938cbb3178fc97125e520e6fa22f4d4ffb21d15daa9e94d2ef6deac1));
        vk.gamma_abc[187] = Pairing.G1Point(uint256(0x296e7e0a94763cbce592cdb4602cee217df01d8dac9e2f381f3658fb5016e5d9), uint256(0x0832b865156ebc3570ed5eb2fe2af979c30c5871fa22fc47da5a7b08d10f6acd));
        vk.gamma_abc[188] = Pairing.G1Point(uint256(0x26230ad662b4b63b49b8d272cb162e9c2fc3838217150b020f3e07461e492189), uint256(0x0977ae362d3df9a4f1933e63f675dce5db65d77c0f35f84093ee37e8ca76cfa6));
        vk.gamma_abc[189] = Pairing.G1Point(uint256(0x0ad6f312d37ce6c72e155ed9edb04dba26bee356a2ee7dc8e443b3399b692f86), uint256(0x050fbccc915296bc4d884c731bc557880e9c3949f63eda58cb8aeb0899a2b5ef));
        vk.gamma_abc[190] = Pairing.G1Point(uint256(0x0d11f9c8de0b61a53d13d398caae56d09d29e7452c593fd867ef5145cc6130f6), uint256(0x1982fb74e122d73711709aa30ce63f1c74bcb64bffa919f1c6f2ac7f088bbbc5));
        vk.gamma_abc[191] = Pairing.G1Point(uint256(0x2736150de46e7536385c32de36da30d6daab457274bb3e6082f2edc2b320a1a6), uint256(0x1e3f68a914124382232031233fa6814c012c9c58fde9d01a1c85f1e12a15b7c8));
        vk.gamma_abc[192] = Pairing.G1Point(uint256(0x20f6f8b382a7c67a6cc29245a013f636cad5f6ee1d2dd14e6ef1130f467b0cae), uint256(0x2d7a5721d3d94fe343b4d27416e5be20c5d9ee19b36b30869f182abf4671aa4b));
        vk.gamma_abc[193] = Pairing.G1Point(uint256(0x27dae9d43912b6108161d25d3f191fe26ce0f8709d796781733abcb5ff306c24), uint256(0x1be2dec4951e84e8a6aa2ac46f7c40f95fa02cfbb7c22d4f48a461f07b914887));
        vk.gamma_abc[194] = Pairing.G1Point(uint256(0x0a59902d84a9f67fed1cf41ae0c7d2ea0bbd61d271385713717b313c584f465f), uint256(0x2a41343207b8419a3b263371bb1feb4f619a5dc6f7de81c20578d13978f018f2));
        vk.gamma_abc[195] = Pairing.G1Point(uint256(0x1815ae53d14619c8056702c3e79a2b10cf67a7232cd9161641440fa9cf7ddd7c), uint256(0x0873d361e92719ada236b804235f4d0b72d7ac51714bab1bb932c5b09cc9ff3f));
        vk.gamma_abc[196] = Pairing.G1Point(uint256(0x0d655483bc0535a68277ee4ac5ca849241b3596360d7179e80abc37927111b37), uint256(0x03202632e9486e370eeba39fdd5fb503bf370612203febc2084a406b2998bdc2));
        vk.gamma_abc[197] = Pairing.G1Point(uint256(0x1a4ba351f6648fc62b4bafaa0d5326e475e84631c015cbc43f9328d4b3624642), uint256(0x0651d130ed050c99963ee96c8c9835279f81d44db5b5b23fe05d2dff0bc4ec8d));
        vk.gamma_abc[198] = Pairing.G1Point(uint256(0x2b30435d768d300a91b1b8a3c8bf1acedda1bcfd1d55eff5dff969cae59fe624), uint256(0x158cb931bdbea99f296c697d16d25677f8430397ce1fc305409bd8564f524058));
        vk.gamma_abc[199] = Pairing.G1Point(uint256(0x09b431ff67cbfea47b2503597c1d3bc950fb3b1bfac367d4b4b975baf6339564), uint256(0x1ccf3f1e1474090abafb3ab44be8c9129adbd2a5586cc748ac17f7df371b2aaa));
        vk.gamma_abc[200] = Pairing.G1Point(uint256(0x16c9c89feac86c37a4bdcad857b77880ebc7b2bec82c952025ca01e724f2b6d5), uint256(0x1b5f8b2575d2a12aee3eb2da326b2971a6d33f87b8c279b61e1da5b3117b0c5f));
        vk.gamma_abc[201] = Pairing.G1Point(uint256(0x1d33e09ffaecfde09f1ac13678a675ec4267e746a4948107c2f35756c94c3044), uint256(0x05e313780aa6d0761fbb5db7e917309ae807d9ef85f834e657034da84f0c4755));
        vk.gamma_abc[202] = Pairing.G1Point(uint256(0x2cc2ee4006c64cbba339b004925e7b7313db8903c2a56ee9e5e5a3b00dd6a37c), uint256(0x03d4f0cd20e4df7c391fb799db28155a1be8a46d1633b5e37780328785131ce3));
        vk.gamma_abc[203] = Pairing.G1Point(uint256(0x123cc37224cf0e3981fd3e9a5c727821f5febcaae94b7fb48327a0ceebdc2d7c), uint256(0x2ebeaf42d6751e936879f7436d8492eb4803255731bb9c27654e1de24a40987b));
        vk.gamma_abc[204] = Pairing.G1Point(uint256(0x0b8e768fb298b940beca6d647259c8e6df5ec17eb6825cdc3d608290af9e89a1), uint256(0x0bd932f788de6208cb9ea2d11260c684667f06efd6f4e9f71548791013816a65));
        vk.gamma_abc[205] = Pairing.G1Point(uint256(0x25d5f7b1692b57009fd8efeda879e9c31e4a24a377559fa3962563e3a6fd7c99), uint256(0x1b47dcad7021fbbdb51037191cceff4944c137da3671cf70eda7e9d4de63ae48));
        vk.gamma_abc[206] = Pairing.G1Point(uint256(0x2e059d8b5f65307185a368021a4208d2b54c127be3ee3471fdedbc878e29fb15), uint256(0x215e22dc54971596a8a5819c8dc20695a65cbb7ad7a671c4e808f5a1d0453b46));
        vk.gamma_abc[207] = Pairing.G1Point(uint256(0x21a9da257724a9d6e07a453074dd7cc287f9ec9b63631c532f284eeabe5d3e66), uint256(0x23921be04ffa4859f7a1aeb405719241334ae76c15ceab2e9840b1ff6df4c1ca));
        vk.gamma_abc[208] = Pairing.G1Point(uint256(0x22109f2ff978c2f7e4b6fb5d2ec4b83b05f8d4d7d579793241b57907cea0f09c), uint256(0x0e145fe1e10c58e6cc61d9c802eefa08c8371737bd1db45edda2c88e9430b671));
        vk.gamma_abc[209] = Pairing.G1Point(uint256(0x07e6ea37d46353b7deca29c51e0e72963705688badeb4d3e1b9f3d7869899746), uint256(0x2af4471df79301d8a0196f7b2486bde8949098db31bc2fb8f224ea3b13244966));
        vk.gamma_abc[210] = Pairing.G1Point(uint256(0x2978e2e3394b660b001d7d0ce059202d685ffe12a731e5bf0d6708170d29092a), uint256(0x1388f45c38f17f0f01c2ff07e2b21cda6befa474565dcd21740b33f284e115d1));
        vk.gamma_abc[211] = Pairing.G1Point(uint256(0x20f2609afdda145eadc3984b05a5e51ee16a85bdac1abf47537ab2c08b8aad0b), uint256(0x244c3b3812deff6c41f0e495272aaade6803e27488e656cf1f02f7ad572745a3));
        vk.gamma_abc[212] = Pairing.G1Point(uint256(0x2e1d07ccb08e357b67c940a3d3bd50cd25c739ec931a7091dabe9e421380bd93), uint256(0x2084fb55a66f099bd3611fe7f6ece54da0bb326ad6448dff1cb1aa6d7983c426));
        vk.gamma_abc[213] = Pairing.G1Point(uint256(0x07249176d1b137d110ea7191bcd6d180f976568f22b29b9257dd55bad2399f2a), uint256(0x0415030bfd23856274a0bf428adc1554130993570ac7f9457985d6c44961801d));
        vk.gamma_abc[214] = Pairing.G1Point(uint256(0x1139e6918f5526bdf8b2483a20e5528b4753b8824b2debcc20a9a6d191289b53), uint256(0x20f940c4f2fd34a237610b2cd55e7d33b5f44920a15d3b41393aa3399e5474a5));
        vk.gamma_abc[215] = Pairing.G1Point(uint256(0x0e62f0ea57c1e8eddc68dd78cdcbe38a70e624ae81bc14fbb397a52d89acbc83), uint256(0x22f030107650de4ed1e2b6a92663415d9a0b31c4991d683481fd74b4ed39b0c1));
        vk.gamma_abc[216] = Pairing.G1Point(uint256(0x0f0501179beb9c3847ef893b72634b8232a4c58e66332d1e16acb836aa2dcbad), uint256(0x2196b1c2def53bbcf6f21bee22eb9faaac89af8af57d299c36ab4d17e6045df6));
        vk.gamma_abc[217] = Pairing.G1Point(uint256(0x0225f07d47578875fcb95b888ed6949178b3cc1f08d1edc24f9e43773ca50429), uint256(0x20cd957d990d839a95a3aa87d28241fac14268366c66ca047c99e59f34bd3388));
        vk.gamma_abc[218] = Pairing.G1Point(uint256(0x1b7cebd830a8e33b51dde856870c97dcdb293c74718e39527f8e4c91ebf15206), uint256(0x05e4bfcaeb237149ef333b0f3e79462e59339ad6a30fd5c9c5b70eeede4153bd));
        vk.gamma_abc[219] = Pairing.G1Point(uint256(0x0845e615451ead92602370564e471251a2d93d365e8d3f106f5a641d3e77935d), uint256(0x000b2bac1b099bc55a081c7627fc6aef84a8987933eaa5deb33928865cdbf2a6));
        vk.gamma_abc[220] = Pairing.G1Point(uint256(0x1573f24a9dc8c01b6c95b74ebd464b181a8d431c5c18245349fd05b71587c767), uint256(0x1a779322545d58ecef093ab98c7238648efacbd9081b5b2715d2133f61c7ffd1));
        vk.gamma_abc[221] = Pairing.G1Point(uint256(0x0069da6ba9fb0fb218f214a22551dd739772f9692d80d4e6e536f33f859a54ee), uint256(0x2c90742c152512a06e4683d8ec6658bb8737c81b95148184e13235855b17a715));
        vk.gamma_abc[222] = Pairing.G1Point(uint256(0x19694fe6cc5d2ef3af2bc9ca50587c489dbc866128fb40eef4e0c453c7655ee1), uint256(0x25b1e7dd3a2a93374d1a8dd464dc4c3f84c73e4226dbb29c40d01137d96b5125));
        vk.gamma_abc[223] = Pairing.G1Point(uint256(0x28d5ccb430d3a7af66993ee1e84ae17cf1e3a7a21dda43c879042d8d594f1afa), uint256(0x0e05a5525173abd968033a9ba2d7dd91477a572ff08cba1496b97e7955b7ae56));
        vk.gamma_abc[224] = Pairing.G1Point(uint256(0x2fbbd09676ea66226fa3c0e60d8cc71a02118848f2f7f92f9f8e0fff3b966678), uint256(0x2274eb2b649ab95828fba4da6d8bfd7074803662866dbab468e0f18a5e5e9c3e));
        vk.gamma_abc[225] = Pairing.G1Point(uint256(0x2e084bb30561eb3d6777afb0447ce43f9a312b0318c06420277eb6d3cd5d8ee0), uint256(0x1050370b7fd7754756cc092ccaf01c055d550596a110df3739a246a467c410cd));
        vk.gamma_abc[226] = Pairing.G1Point(uint256(0x08ab5d852ac56d5f0c2d81b8e03390ba7b960567f8ddf454d45ef49419d5a2b7), uint256(0x0cc035aa02e981060a46b92fe059f3488c229aba70252de0426ff0881001d4cd));
        vk.gamma_abc[227] = Pairing.G1Point(uint256(0x0fd9bd663ada87d9d16992b7287576ea9ed8476a8b4efb6ccc3ac9998518e055), uint256(0x181c143d8ec2574f298769c8a28bc6b93715a54ad1d80d4c5f42636c376ce657));
        vk.gamma_abc[228] = Pairing.G1Point(uint256(0x2103809912b584c920ab1eb24278fd3cf0104701b0904ccda7de59866d0246aa), uint256(0x1572286297b3f738a21c1638fea0e5518b765e4f76039ac75b3fb2ed385f01bf));
        vk.gamma_abc[229] = Pairing.G1Point(uint256(0x1b41a46c0f9bfee174c944a4faaa5a6d41b31f025b418fbbf505012e7cd3c430), uint256(0x0855516432e991ed449a30d7145d2f49f0b47a6d6c6be609bd68f1860970e1ad));
        vk.gamma_abc[230] = Pairing.G1Point(uint256(0x0b5c237244cfae7e136efb76829b5fae53bd2a607c47d5d97515e7cc492bb545), uint256(0x24719bc4e9bce6e45b9aa8b9ba239e1cd55d6240a462fed8b2d47f034e0019c2));
        vk.gamma_abc[231] = Pairing.G1Point(uint256(0x1c344ecbfccd9d410cfde4e4ec39ad42e1a17723264e48fe20ec7b2b59092625), uint256(0x2d4716695350455fa82f1869b6d432c314550884d9c1b94347c7d45e87b47168));
        vk.gamma_abc[232] = Pairing.G1Point(uint256(0x2d086b8a8a266c90305a53106dfefe5fee16b2d4753b6ae1a3342ba3d0437292), uint256(0x1af4c5ce76faf8b54aced77e1eca013407dc5aaeee79c2550dfeefd05077cec7));
        vk.gamma_abc[233] = Pairing.G1Point(uint256(0x2e8ca2e9c7e679f267426f93ffa3804795aafe571034f6414d3a4802b3e0cce9), uint256(0x0d3015cbcad7c663cdb091f74feee82214c7c6db144f10338a6ce4de6de88dfa));
        vk.gamma_abc[234] = Pairing.G1Point(uint256(0x06af9fdca26269e12d7f11687f45eb25d67e8544af87b8dce738d5dbae04bac3), uint256(0x102967a30fb73e6153cc552a961130fc12181e0536a281c7b59990228318cb89));
        vk.gamma_abc[235] = Pairing.G1Point(uint256(0x0486d5b14c31609466ad9b87fb824653828d66b76fab5ad86e3d1ca07e9937f9), uint256(0x053069e55dee99d107d98debec175a8ce4a4794a2e7bf88bf9bcfba775219f4a));
        vk.gamma_abc[236] = Pairing.G1Point(uint256(0x1c2a67ddcc66c17003e77dca69ffcdd1b2b38004c92898dc83978d4b6f18e8c3), uint256(0x2f5f24a1d66a3b9231909d6909f00ad39b8ac568abc94d8c666f67e248858845));
        vk.gamma_abc[237] = Pairing.G1Point(uint256(0x045e4c269f66aa84214d154321437876c9770f65425da26b344fb8781176da05), uint256(0x2c9a177622334389c396117f516012327e4afa08e767cf4253b34274751a99ec));
        vk.gamma_abc[238] = Pairing.G1Point(uint256(0x10c7d915b5bc600e9f016e85ff9452426aeed6baf4a51578d9709cae3f733879), uint256(0x008bdc90a8e22136c9b13bd4c4214b3a556082b854e8826122704c1a0e6daf0a));
        vk.gamma_abc[239] = Pairing.G1Point(uint256(0x0b677374377b768e7e7435ca35ece4ba32dc05e25d54ae5616b2d8f569c900a3), uint256(0x1f24bc335f3c08721fd3558e39bf9357735ae8b67d151b8be930c5fc4a97c42f));
        vk.gamma_abc[240] = Pairing.G1Point(uint256(0x1890a0eb2d34e5d29f7f18e6855eda5f8d18e6fea44de8586e33b71a45b34ec9), uint256(0x076b249d90dbdbc5c1df78673332e120a7a6f9db61d1a8163bd74462c9b18df9));
        vk.gamma_abc[241] = Pairing.G1Point(uint256(0x20ab9b5cec502f560d56bebb7ddbd30ee870f571a00913b21be1f532b34a24f0), uint256(0x047afa13f3839b1f2d92cdc41b928aeb8cb1a8a1feb85089fdbafd2db44b4752));
        vk.gamma_abc[242] = Pairing.G1Point(uint256(0x1d94d6805f71af513de5e9bdb034d1d78d3cfb4e9d925fa76841135b3e0b7e52), uint256(0x273479c4840f869dc04983fc384b1bdd6a5f074aa53d6cf2631cdcf40119646b));
        vk.gamma_abc[243] = Pairing.G1Point(uint256(0x0c02806cf81fa0b09fbe9d90105fd26ea671fb5301490f5dc7558efbbd54f1aa), uint256(0x2a80fa01241b7dcdb905577322dfd49eef46d06035eae1aa1563a50511040d37));
        vk.gamma_abc[244] = Pairing.G1Point(uint256(0x1e7badc1b7df126f10024c52e62822c4504ee930e76e5e9a1856d1a3193f2093), uint256(0x0dabc93500ae552b96ea64748fce6a3eeb5aba12c7162ccc70d84509dfd48841));
        vk.gamma_abc[245] = Pairing.G1Point(uint256(0x1b8ec184d803b3cd66c5cf18b390d3d5fcfc87f8414b9a9eb5bd7a94a51b442d), uint256(0x2b6797f29b1bc97bc93385b8636031192e2363e6d74b3c3626e113bdb4d34a88));
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
            Proof memory proof, uint[245] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](245);
        
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
