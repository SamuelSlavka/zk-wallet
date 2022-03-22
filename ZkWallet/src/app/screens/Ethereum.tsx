import React from 'react';
import {Text} from 'react-native';

import '../utilities/global';
import {NativeModules, Button, Alert} from 'react-native';

const Ethereum = () => {
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
