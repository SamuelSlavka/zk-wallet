# Mobile Cryptocurrency Wallet Based on zk-SNARKs and Smart Contracts

## A client-server framework for mobile wallet that will utilize zk-SNARKs as a storage optimization technique.

### Server setup
#### build docker and compile zokratess program
    make init
#### run dockerized flask
    make dev
#### start flask and also local instance of geth light node
    make start
#### compile and setup zokrates
    make compile
#### create witness for current smartContracts/zokrates/zokratesInput file
    make witness
#### deploy current vesion of smart contract in smartContracts/build/contracts (created in make compile)
    make deploy 

### Client setup
  Fully described in ZkWallet
  
    yarn react-native start
    yarn react-native run

