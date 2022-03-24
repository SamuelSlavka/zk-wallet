import React from 'react';

import '../utilities/global';
import {NativeModules, Button, Alert} from 'react-native';

const Ethereum = () => {
  return (
    <>
      <Button
        title="get address"
        onPress={() => {
          NativeModules.CommunicationNative.getAddress((str: any) => {
            Alert.alert(str);
          });
        }}
      />
      <Button
        title="setup account"
        onPress={() => {
          NativeModules.CommunicationNative.setupAccount(
            'password',
            'exportPassword',
            (str: any) => {
              Alert.alert(str);
            },
          );
        }}
      />
      <Button
        title="load account"
        onPress={() => {
          NativeModules.CommunicationNative.loadAccount(
            'setupResult',
            'exportPassword',
            'password',
            (str: any) => {
              Alert.alert(str);
            },
          );
        }}
      />
      <Button
        title="call contract"
        onPress={() => {
          NativeModules.CommunicationNative.callContract('str', (str: any) => {
            Alert.alert(str);
          });
        }}
      />
    </>
  );
};

export default Ethereum;
