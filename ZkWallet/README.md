# React native wallet with local ethereum light node
Inherently runs in reinkeby testnet (defined in MainActivity)
Eth interaction is done trought wrapper on top of Go.
React native acceses this wrapper trough Native Modeule: `CommunucationNative`


## setup
    yarn install
    yarn postinstall

## run app
    yarn react-native run-android


## run metro
    yarn react-native start


## dev env (for me :))
    cd ~/Android/Sdk/emulator && ./emulator -avd Pixel_5_API_30
    adb logcat