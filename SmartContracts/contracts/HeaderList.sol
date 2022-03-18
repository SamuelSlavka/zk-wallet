pragma experimental ABIEncoderV2;

contract HeaderList {
    address public validationContract;
    uint private headerchainTop = 0;

    constructor(address contractAddress) {
        validationContract = contractAddress;
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

    function validateProof(string hash, uint number, string zokratesInput) public {
        // leaving 10 block space for forks
        if(number+10 > headerchainTop) {
            Duplicates[] duplicateHeaders = headers[number];
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
