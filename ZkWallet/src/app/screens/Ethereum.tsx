import React, {useEffect} from 'react';
import {useSelector, useDispatch} from 'react-redux';
import {
  getBalance,
  loadAccount,
  newAccount,
  getAddress,
  getInfo,
  getClosestHash,
} from '../redux/actions';
import {RootState} from '../redux/store';

import {NativeModules, Button, Alert, Text, SafeAreaView} from 'react-native';

const Ethereum = () => {
  const {ethBalance, keyfile, ethAddress, contract, closestHash} = useSelector(
    (state: RootState) => state.ethereumReducer,
  );
  const dispatch = useDispatch();

  const getEthBalance = () => dispatch(getBalance());
  const getEthAddress = () => dispatch(getAddress());
  const getContractInfo = () => dispatch(getInfo());

  const newEthAccount = (password: string, exportPassword: string) =>
    dispatch(newAccount(password, exportPassword));
  const loadEthAccount = (
    setupResult: string,
    password: string,
    exportPassword: string,
  ) => dispatch(loadAccount(setupResult, password, exportPassword));

  const getHash = (password: string, height: number) =>
    dispatch(
      getClosestHash(
        password,
        contract.contract_address,
        JSON.stringify(contract.abi),
        height,
      ),
    );

  useEffect(() => {
    // create new account if empty or broken
    if (keyfile === '' || keyfile === 'error') {
      newEthAccount('password', 'exportPassword');
    }
    getEthBalance();
    getEthAddress();
    getContractInfo();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <SafeAreaView>
      <Text>{ethAddress}</Text>
      <Text>{ethBalance}</Text>
      <Text>{contract.contract_address}</Text>
      <Text>{closestHash}</Text>
      <Button
        title="refresh"
        onPress={() => {
          getEthBalance();
          getEthAddress();
          getContractInfo();
        }}
      />
      <Button
        title="setup account"
        onPress={() => {
          newEthAccount('password', 'exportPassword');
        }}
      />
      <Button
        title="load account"
        onPress={() => {
          loadEthAccount(keyfile, 'password', 'exportPassword');
        }}
      />
      <Button
        title="get Closest Hash"
        onPress={() => {
          getHash('password', 40);
        }}
      />
      <Button
        title="send transaction"
        onPress={() => {
          // String password, String receiver, int amount, String jsonTransaction, String data_string
          NativeModules.CommunicationNative.sendTransaction(
            'password',
            '0xa7e4ef0a9e15bdef215e2ed87ae050f974ecd60b',
            0.0001,
            'data',
            (str: any) => {
              Alert.alert(str);
            },
          );
        }}
      />
    </SafeAreaView>
  );
};

export default Ethereum;
