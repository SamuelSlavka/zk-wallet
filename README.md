# Mobile Cryptocurrency Wallet Based on zk-SNARKs and Smart Contracts

### A framework for mobile wallet that utilizes zk-SNARKs as a storage optimization technique. 
Server is able to create zk-SNARK proofs of headers batch validity and publish them to smart contract. Client uses these proofs as checkpoints for its local header chain.

## Initial setup

For each file ending with `.dist` create file with the same name with the same contents, but without `.dist` ending. Afterwadrs replace all `REPLACEME` values with your prefered configuration.
It is more consisely described in respective READMEs

## Server setup

Server uses rest api for providing up to date Contract address and abi. You can configure them in the app as constants and server will be unecessary.
#### Build docker and compile zokratess program

    make init

#### Run dockerized flask

    make dev

## Smart contracts setup
#### Compile and setup zokrates (warning creates toxic waste)

    make compile

Compilation is heavily dependant on number of headers in batches with proportional increase in ram:
- 16 headers ~10GB ram local setup time: 20 minutes
- 32 headers ~15GB ram local setup time: 40 minutes
- 64 headers >30GB ram failed

Currently zokrates is predefined for 32 header batches

#### Deploy current vesion of smart contract in smartContracts/build/contracts
Uses validator created in `make compile`. Deploys to predefined provider in `constants.py`

    make deploy 

blockchain ids are constants set in smart contract:

- 0 - btc starting in genesis  
- 1 - btc starting in some test block   
- 2 - bch starting in genesis
- 3 - bch starting in some test block


#### Custom proof and witness creation
    
    main.py proof [blockchainId] [start height] [end height]

Witness generation:
- 16 headers ~5GB ram time: 1:15s
- 32 headers ~7GB ram time: 2:40s

Proof generation:
- 32 headers ~10GB ram time: 6:30s

#### Custom interaction 
    
    main.py interact [blockchainId] [start height] [end height]


#### For zokrates and smart contract testing:
create proof default for btc headers 0 to 32 and send it to contract 

    make proof

    make interact


## Client setup
  Fully described in ZkWallet
  
    yarn react-native start

    yarn react-native run

