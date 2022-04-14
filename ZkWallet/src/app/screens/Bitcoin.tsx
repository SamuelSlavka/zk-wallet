import React, {useEffect} from 'react';
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
import {BtcTransaction} from '../redux/btcModels';

import {
  getBtcHeaders,
  getBalanceSummary,
  getClosestHash,
} from '../redux/btc/btcActions';
import {getInfo} from '../redux/ethActions';

// const BitcoinJs = require('react-native-bitcoinjs-lib');
// const BtcProof = require('bitcoin-proof');

const address = '37Q13UiqZz4mkyuumyzKifSdApa5Bk3TV5';

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
  const {
    btcHeaders,
    btcCreadentails,
    btcTransactions,
    btcBalance,
    btcClosestHash,
  } = useSelector((state: RootState) => state.bitcoinReducer);
  const {contract} = useSelector((state: RootState) => state.ethereumReducer);

  const dispatch = useDispatch();

  const refreshData = () => {
    dispatch(getBalanceSummary(address));
    dispatch(getInfo());
    dispatch(getBtcHeaders(0, 3));

    // setup creadentials in prenament storage
    btcCreadentails.address = address;
    console.log(btcCreadentails.address);
  };

  const getHash = (password: string, height: number) =>
    dispatch(
      getClosestHash(
        0,
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

  const listItems = btcTransactions.map((transaction: BtcTransaction) => (
    <View key={transaction.tx_hash}>
      <Text key={'1'}>tx: {transaction.tx_hash}</Text>
      <Text key={'2'}>at: {transaction.block_height}</Text>
      <Text key={'3'}>in bl: {transaction.block_index}</Text>
      <Text key={'4'}>spent: {transaction.spending_tx_hash}</Text>
      <Text key={'5'}>val: {transaction.validated?.toString()}</Text>
    </View>
  ));

  return (
    <SafeAreaView>
      <ScrollView>
        <Text style={styles.header}>Last stored header:</Text>
        <Text>{btcHeaders?.[btcHeaders.length - 1]?.hash}</Text>
        <Text style={styles.header}>Closest hash:</Text>
        <Text>{btcClosestHash.hash}</Text>
        <Text style={styles.header}>Contract address:</Text>
        <Text>{contract.contract_address}</Text>
        <Text style={styles.header}>Your address:</Text>
        <Text>{btcCreadentails.address}</Text>
        <Text style={styles.header}>Your balance:</Text>
        <Text>{btcBalance}</Text>
        <Text style={styles.header}>Your txses:</Text>
        <View>{listItems}</View>
        <Button
          title="Get Closest Hash"
          onPress={() => {
            getHash(
              'password',
              50,
              // todo
              // parseInt(btcHeaders?.[btcHeaders.length - 1]?.height, 10),
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
            dispatch(getBtcHeaders(2, 4));
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
