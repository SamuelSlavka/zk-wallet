pragma experimental ABIEncoderV2;

contract HeaderList {
    address public validationContract;
    uint private headerchainTop = 0;

    constructor(address validatorAddress) {
        validationContract = validatorAddress;
    }

    struct Header {
        string hash;
        string number;
    }

    struct Duplicates {
        //headers at the same number defined by their hash
        mapping(string => Header) duplicates;
    }

    // list of all headers defined by their number
    mapping(uint => Duplicates) private btcHeaders;

    function validateProof(uint256 hash, uint number, string zokratesInput) public {
        // leaving 10 block space for forks
        // hash has to be at least under maximum target refs https://en.bitcoin.it/wiki/Target
        if(number+10 > headerchainTop && hash > 0x00000000FFFF0000000000000000000000000000000000000000000000000000) {
            Duplicates[] duplicateHeaders = btcHeaders[number];
            if(callValidatorContract(zokratesInput)) {
                duplicateHeaders[hash] = Header(hash,number);
            }
        }
    }

    function callValidatorContract(string zkInput) {

    }

    function appendHeader(Header result) public {
        require(msg.sender == validationContract);
    }

    function getLatestHeader() public {  
    }
}
