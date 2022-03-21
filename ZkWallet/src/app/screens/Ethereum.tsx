import React from 'react';
import {Text} from 'react-native';

import '../utilities/global';
import Web3 from 'web3';
import {NativeModules, Button, Alert} from 'react-native';

const Ethereum = () => {
  const web3 = new Web3(
    new Web3.providers.HttpProvider('http://127.0.0.1:8545'),
  );

  web3.eth.getBlock('latest').then(console.log);

  return (
    <>
      <Button
        title="button"
        onPress={() => {
          NativeModules.CommunicationNative.test('str', (str: any) => {
            Alert.alert(str);
          });
        }}
      />
      <Text> ETH </Text>
    </>
  );
};

export default Ethereum;
