# Mobile Cryptocurrency Wallet Based on zk-SNARKs and Smart Contracts

### A client-server framework for mobile wallet that will utilize zk-SNARKs as a storage optimization technique.

## Initial setup
For each file ending with .dist create file with the same name with the same contents, but without .dist ending. Afterwadrs replace all REPLACEME values with your prefered configuration.

## Server setup
#### build docker and compile zokratess program
    make init
#### run dockerized flask
    make dev
#### start flask and also local instance of geth light node
    make start

## Smart contracts setup
#### compile and setup zokrates
    make compile

Compilation is heavily dependant on number of headers in batches with proportional increase in ram:
- 16 headers ~10GB ram local setup time: 20 minutes
- 32 headers ~15GB ram local setup time: 40 minutes
- 64 headers >30GB ram failed

#### create proof for current smartContracts/zokrates/zokratesInput file
    make proof

Witness generation:
- 16 headers ~5GB ram time: 1:15s
- 32 headers ~7GB ram time: 2:40s

Proof generation
- 32 headers ~10GB ram time: 6:00s


#### deploy current vesion of smart contract in smartContracts/build/contracts (created in make compile)
    make deploy 

## Client setup
  Fully described in ZkWallet
  
    yarn react-native start
    yarn react-native run

