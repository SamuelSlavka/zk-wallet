import React, {useEffect} from 'react';
import {useSelector, useDispatch} from 'react-redux';
import {
  getBalance,
  newAccount,
  getAddress,
  sendTransaction,
  getInfo,
} from '../redux/ethActions';

import ButtonComponent from '../components/ButtonComponent';
import {RootState} from '../redux/store';
import {Text, SafeAreaView, StyleSheet} from 'react-native';

const Ethereum = () => {
  const {ethBalance, keyfile, ethAddress, contract} = useSelector(
    (state: RootState) => state.ethereumReducer,
  );
  const dispatch = useDispatch();

  const refreshData = () => {
    console.log(ethAddress);
    dispatch(getBalance());
    dispatch(getAddress());
    dispatch(getInfo());
  };

  const sendEthTransaction = () => {
    dispatch(
      sendTransaction(
        'password',
        '0x07A65AF32e0a4D5Fb2A074b050133971c937fFC0',
        0.001,
      ),
    );
  };

  const newEthAccount = (password: string, exportPassword: string) =>
    dispatch(newAccount(password, exportPassword));

  useEffect(() => {
    // create new account if empty or broken
    if (keyfile === '' || keyfile === 'error') {
      newEthAccount('password', 'exportPassword');
    }
    refreshData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <SafeAreaView>
      <Text style={styles.header}>Your address:</Text>
      <Text>{ethAddress}</Text>
      <Text style={styles.header}>Your balance:</Text>
      <Text>{ethBalance}</Text>
      <Text style={styles.header}>Contract address:</Text>
      <Text>{contract.contract_address}</Text>
      <ButtonComponent
        title="refresh"
        callback={() => {
          refreshData();
        }}
      />
      <ButtonComponent
        title="setup account"
        callback={() => {
          newEthAccount('password', 'exportPassword');
        }}
      />
      <ButtonComponent
        title="send transaction"
        callback={() => {
          sendEthTransaction();
        }}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  header: {
    fontWeight: 'bold',
    fontSize: 16,
  },
});

export default Ethereum;
