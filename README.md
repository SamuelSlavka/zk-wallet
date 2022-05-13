# Mobile Cryptocurrency Wallet Based on zk-SNARKs and Smart Contracts

### A framework for mobile wallet that utilizes zk-SNARKs as a storage optimization technique. 
Server is able to create zk-SNARK proofs of headers batch validity and publish them to smart contract. Client uses these proofs as checkpoints for its local header chain.

## Requirements
- docker
- docker-compose
- yarn
- metro

## Server setup
Server uses rest api for providing up to date Contract address and abi. You can configure them in the app as constants and server will be unecessary. Constants and functionality are fully described in `./Server/README.md` 

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

Included zokrates setup is predefined for 32 header batches

#### Deploy current vesion of smart contract in smartContracts/build/contracts
Uses validator genereated during `make compile`. Deploys to predefined provider in `constants.py`

    make deploy 

blockchain ids are constants set in smart contract:

- 0 - btc starting in genesis  
- 1 - btc starting in some test block   
- 2 - bch starting in genesis
- 3 - bch starting in some test block


#### Custom proof and witness creation
will create proofs for 32 header sized chinks starting with [start height] and ending at [end height] if [end height] is lower than start of chunk+32 the proof will be genrated for start of chunk+32 anyway. It is also a computationaly heavy task.

    python3 ./Server/main.py proof [blockchainId] [start height] [end height]

Proof and witness generation:
- 4 headers 1.5 GB ram
- 8 headers 3 GB ram
- 16 headers 6 GB ram
- 32 headers 13 GB ram

#### Proof publishing to smart contracti
Will publish previosuly generated proofs when wider range than 32 the proofs will be batched into single message, creating only one chckpoin. 
    
    python3 ./Server/main.py interact [blockchainId] [start height] [end height]


#### For zokrates and smart contract testing:
Create proof default for btc headers 0 to 32 and send it to the contract.

    make proof

    make interact


## Client setup

  SDK and cosntants are fully described in `./ZkWallet/README.md` 

#### Client dev env execution:

    yarn react-native start

    yarn react-native run


## General testing

Provided makefile also contains an easy to execute shotcuts for testig. It uses previously mentioned python script.
- Creates proof for first 32 headers.
    make proof 
- Submits the previously created proof to smart contract
    make intercat
- Calls clients function to check current head of smart contract header chain.
    make call