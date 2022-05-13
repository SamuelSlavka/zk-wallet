# React native wallet with local ethereum light node
Inherently runs in reinkeby testnet (defined in MainActivity)
Eth interaction is done trought wrapper on top of Go.
React native acceses this wrapper trough Native Modeule: `CommunucationNative`

## dependecies
react-native
yarn

## setup
    yarn install
    yarn postinstall

#### React native constants
Do this if `index.ts` is missing:
rename  `index.ts.dist` to  `index.ts`
- Replace Token and optionaly api urls
- BTC_TOKEN is token from getblock.io for their API

#### Java constants:
Do this if `Constants.java` is missing:
rename `Constants.java.dist` with `Constants.java`
- DEVENV = booleand if false geth will connect to geth directly 
- PROVIDER = if DEVENV geth will use this provider

#### For ganache add the following at the end
- PRIVATE_KEY = PK you get from ganache directly
- ETHPROVIDER = 'HTTP://127.0.0.1:7545'

## run the app
    yarn react-native run-android

## run metro server
    yarn react-native start

## execute the applicaiton 
There are two options: running in emulator or running in android device is not currently supported since contract info needs to be routed to the device from server.
#### Run android emulator 
This has different paths at each system and requires a lot of dependencies basic setup is as follows:
 - Install `SDK` with: `apt install android-sdk`
 - Define location with an `ANDROID_SDK_ROOT` environment variable or by setting the sdk.dir path in your project's local properties file at `/ZkWallet/android/local.properties`, usually as `sdk.dir = /Users/USERNAME/Library/Android/sdk`
 - Install emulator name [emulator] with avdmanager
    cd ~/Android/Sdk/emulator && ./emulator -avd [emulator]


