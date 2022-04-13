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
import {
  getBtcHeaders,
  getBalanceSummary,
  getClosestHash,
} from '../redux/bchActions';
import {getInfo} from '../redux/ethActions';
import {BtcTransaction} from '../redux/btcModels';

const address = 'qrn29uc480r8ra8yvfyuzr35dhrs776hgye0fqpnem';

const BitcoinCash = () => {
  const {
    bchHeaders,
    bchCreadentails,
    bchTransactions,
    bchBalance,
    bchClosestHash,
  } = useSelector((state: RootState) => state.bitcoinCashReducer);
  const {contract} = useSelector((state: RootState) => state.ethereumReducer);

  const dispatch = useDispatch();

  const refreshData = () => {
    dispatch(getBalanceSummary(address));
    dispatch(getInfo());
    dispatch(getBtcHeaders(0, 3));

    // setup creadentials in prenament storage
    bchCreadentails.address = address;
    console.log(bchCreadentails.address);
  };

  const getHash = (password: string, height: number) =>
    dispatch(
      getClosestHash(
        1,
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
  const listItems = bchTransactions.map((transaction: BtcTransaction) => (
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
        <Text>{bchHeaders?.[bchHeaders.length - 1]?.hash}</Text>
        <Text style={styles.header}>Closest hash:</Text>
        <Text>{bchClosestHash}</Text>
        <Text style={styles.header}>Contract address:</Text>
        <Text>{contract.contract_address}</Text>
        <Text style={styles.header}>Your address:</Text>
        <Text>{bchCreadentails.address}</Text>
        <Text style={styles.header}>Your balance:</Text>
        <Text>{bchBalance}</Text>
        <Text style={styles.header}>Your txses:</Text>
        <View>{listItems}</View>
        <Button
          title="Get Closest Hash"
          onPress={() => {
            getHash(
              'password',
              50,
              // todo
              // parseInt(bchHeaders?.[bchHeaders.length - 1]?.height, 10),
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
            dispatch(getBtcHeaders(90, 96));
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

export default BitcoinCash;
