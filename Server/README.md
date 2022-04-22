# Server side

### Setup instructions:
#### Constnts:
rename  `constants.dist.py` to  `constants.py`

`PRIVATE_KEY` = Ethereum privateky from your chosen network with enought eth for contract deployment and interactions.

Replace Tokens and optionaly api urls.

#### Java constants:
replace Constants.java.dist with Constants.java
- DEVENV = booleand if false geth will connect to geth directly 
- PROVIDER = if DEVENV geth will use this provider

#### SDK
Define location with an `ANDROID_SDK_ROOT` environment variable or by setting the sdk.dir path in your project's local properties file at `/ZkWallet/android/local.properties`
usually as `sdk.dir = /Users/USERNAME/Library/Android/sdk`

#### For ganache add the following at the end

- PRIVATE_KEY = PK you get from ganache directly
- ETHPROVIDER = 'HTTP://127.0.0.1:7545'

#### Client execution
    yarn react-native start

    yarn react-native run

