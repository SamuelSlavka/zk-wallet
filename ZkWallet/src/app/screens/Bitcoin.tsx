import React, {useEffect, useState} from 'react';
import {
  Text,
  SafeAreaView,
  Button,
  StyleSheet,
  View,
  ScrollView,
} from 'react-native';
import {useSelector, useDispatch} from 'react-redux';
import {RootState} from '../redux/store';

import {getBtcHeaders, getBalanceSummary} from '../redux/btcActions';
import {getClosestHash, getInfo} from '../redux/ethActions';

import '../../../shim';
const BitcoinJs = require('react-native-bitcoinjs-lib');
const address = '1K6w2cHX8ZBE6mWS6YgunWjgGnq4XzvYDW';

// const initWallet = async () => {
//   let masterKeychain = null;
//   let action = 'none';

//   const backupPhrase: string = 'phrase';
//   console.log(backupPhrase);
//   const seedBuffer = await bip39.mnemonicToSeed(backupPhrase);
//   masterKeychain = await bitcoin.HDNode.fromSeedBuffer(seedBuffer);
//   let keychain = {
//     backupPhrase: backupPhrase,
//     masterKeychain: masterKeychain,
//     action: action,
//   };
//   return keychain;
// };

const Bitcoin = () => {
  const [balance, setBalance] = useState(0);
  const {btcHeaders, btcCreadentails, btcTransactions} = useSelector(
    (state: RootState) => state.bitcoinReducer,
  );
  const {closestHash, contract} = useSelector(
    (state: RootState) => state.ethereumReducer,
  );

  const dispatch = useDispatch();

  const refreshData = () => {
    dispatch(getBalanceSummary(address));
    dispatch(getInfo());
    dispatch(getBtcHeaders(0, 3));
    // calculate total from transactions
    const initialValue = 0;
    const totalBalance = btcTransactions.reduce(
      (previousValue, currentValue) => previousValue + currentValue.value,
      initialValue,
    );
    setBalance(totalBalance);

    // setup creadentials in prenament storage
    if (btcCreadentails.address === '') {
      try {
        const keyPair = new BitcoinJs.ECPair.fromWIF(
          'KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn',
        );
        btcCreadentails.address = keyPair.getAddress();
      } catch (error) {
        console.error(error);
      }
    }
  };

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
    refreshData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const listItems = btcTransactions.map(transaction => (
    <Text key={transaction.tx_hash}>{transaction.tx_hash}</Text>
  ));

  return (
    <SafeAreaView>
      <ScrollView>
        <Text style={styles.header}>Last stored header:</Text>
        <Text>{btcHeaders?.[btcHeaders.length - 1]?.hash}</Text>
        <Text style={styles.header}>Closest hash:</Text>
        <Text>{closestHash}</Text>
        <Text style={styles.header}>Contract address:</Text>
        <Text>{contract.contract_address}</Text>
        <Text style={styles.header}>Your address:</Text>
        <Text>{btcCreadentails.address}</Text>
        <Text style={styles.header}>Your balance:</Text>
        <Text>{balance}</Text>
        <Text style={styles.header}>Your txses:</Text>
        <View>{listItems}</View>
        <Button
          title="Get Closest Hash"
          onPress={() => {
            getHash(
              'password',
              parseInt(btcHeaders?.[btcHeaders.length - 1]?.height, 10),
            );
          }}
        />
        <Button
          title="Refresh"
          onPress={() => {
            refreshData();
          }}
        />
        <Button
          title="Get headers"
          onPress={() => {
            dispatch(getBtcHeaders(40, 42));
          }}
        />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  header: {
    fontWeight: 'bold',
    fontSize: 16,
  },
});

export default Bitcoin;
