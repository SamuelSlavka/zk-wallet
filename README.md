# Mobile Cryptocurrency Wallet Based on zk-SNARKs and Smart Contracts

### A framework for mobile wallet that utilizes zk-SNARKs as a storage optimization technique. 
Server is able to create zk-SNARK proofs of headers batch validity and publish them to smart contract. Client uses these proofs as checkpoints for its local header chain.

## Requirements
- docker
- docker-compose
- yarn
- metro
- python3

## Server setup
Server uses rest api for providing up to date Contract address and abi. You can configure them in the app as constants and server will be unecessary. Constants and functionality are fully described in `./Server/README.md` 

#### Build docker and compile zokratess program

    make init

#### Run dockerized flask

    make dev

## Smart contracts setup
#### Compile and setup zokrates (warning creates toxic waste)
Included zokrates setup is predefined for 32 header batches

    make compile

#### Deploy current vesion of smart contract in smartContracts/build/contracts
Uses validator genereated during `make compile`. Deploys to predefined provider in `constants.py`

    make deploy 

blockchain ids are constants set in smart contract:

- 0 - btc starting in genesis  
- 1 - btc starting in a test block   
- 2 - bch starting in genesis
- 3 - bch starting in a test block


#### Custom proof and witness creation
will create proofs for 32 header sized chinks starting with [start height] and ending at [end height] if [end height] is lower than start of chunk+32 the proof will be genrated for start of chunk+32 anyway. It is also a computationaly heavy task.

    python3 ./Server/main.py proof [blockchainId] [start height] [end height]

#### Proof publishing to smart contract
Will publish previosuly generated proofs when wider range than 32 the proofs will be batched into single message, creating only one chckpoin. 
    
    python3 ./Server/main.py interact [blockchainId] [start height] [end height]


## Client setup

  SDK and cosntants are fully described in `./ZkWallet/README.md` 

#### Client dev env execution:

    yarn react-native start

    yarn react-native run

## File structure
    ./Nginx - proxy point
    ./Server - server implementation
        /src/bitcoin - bitcoin data gathering and parsing implementation
        /src/ethereum - ethereum contract deployment and interaction
        /src/utils - general utils
        /src/smartContracts - contracts and zokrates handlers
            /contracts  - contract programs
            /zokrates - zokrates program and generated data
    ./ZkWallet - wallet implementation
        /android/app/src/main/java/com/zkwallet - Native module implementation with geth instatiation
        /src - main react native module
            /app - app files
                /components - app components
                /config - global constants
                /navigation - navigation configuration
                /redux - state managment
                /screens - screen components
                /utilities - general utilities
    ./Zokrates - functioning zokrates toolbox

## General testing

Provided makefile also contains an easy to execute shotcuts for testig. It uses previously mentioned python script.
- Creates proof for first 32 headers.
    make proof 
- Submits the previously created proof to smart contract
    make intercat
- Calls clients function to check current head of smart contract header chain.
    make call