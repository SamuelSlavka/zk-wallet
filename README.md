# Mobile Cryptocurrency Wallet Based on zk-SNARKs and Smart Contracts

### A client-server framework for mobile wallet that will utilize zk-SNARKs as a storage optimization technique.

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

#### create witness for current smartContracts/zokrates/zokratesInput file
    make witness

Witness generation:
- 16 witenss ~5 gb ram time: 1:15
- 32 witness ~12 gb ram time: 1:50

#### deploy current vesion of smart contract in smartContracts/build/contracts (created in make compile)
    make deploy 

## Client setup
  Fully described in ZkWallet
  
    yarn react-native start
    yarn react-native run

