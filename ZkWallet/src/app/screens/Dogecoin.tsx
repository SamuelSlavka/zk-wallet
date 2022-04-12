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

import {getBtcHeaders, getBalanceSummary} from '../redux/dogeActions';
import {getClosestHash, getInfo} from '../redux/ethActions';
import {BtcTransaction} from '../redux/btcModels';

import '../../../shim';

const address = 'DJVuMyGR4pxiQn8o6nqAX8D4yZaF9BkBmz';

const Dogecoin = () => {
  const {dogeHeaders, dogeCreadentails, dogeTransactions, dogeBalance} =
    useSelector((state: RootState) => state.dogecoinReducer);
  const {closestHash, contract} = useSelector(
    (state: RootState) => state.ethereumReducer,
  );

  const dispatch = useDispatch();

  const refreshData = () => {
    dispatch(getBalanceSummary(address));
    dispatch(getInfo());
    dispatch(getBtcHeaders(0, 3));

    // setup creadentials in prenament storage
    dogeCreadentails.address = address;
    console.log(dogeCreadentails.address);
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
  const listItems = dogeTransactions.map((transaction: BtcTransaction) => (
    <View key={transaction.tx_hash}>
      <Text key={'1'}>tx: {transaction.tx_hash}</Text>
      <Text key={'2'}>at: {transaction.block_index}</Text>
      <Text key={'3'}>in bl: {transaction.block_hash}</Text>
      <Text key={'4'}>at: {transaction.block_height}</Text>
      <Text key={'5'}>val: {transaction.validated?.toString()}</Text>
    </View>
  ));

  return (
    <SafeAreaView>
      <ScrollView>
        <Text style={styles.header}>Last stored header:</Text>
        <Text>{dogeHeaders?.[dogeHeaders.length - 1]?.hash}</Text>
        <Text style={styles.header}>Closest hash:</Text>
        <Text>{closestHash}</Text>
        <Text style={styles.header}>Contract address:</Text>
        <Text>{contract.contract_address}</Text>
        <Text style={styles.header}>Your address:</Text>
        <Text>{dogeCreadentails.address}</Text>
        <Text style={styles.header}>Your balance:</Text>
        <Text>{dogeBalance}</Text>
        <Text style={styles.header}>Your txses:</Text>
        <View>{listItems}</View>
        <Button
          title="Get Closest Hash"
          onPress={() => {
            getHash(
              'password',
              parseInt(dogeHeaders?.[dogeHeaders.length - 1]?.height, 10),
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
            dispatch(getBtcHeaders(729325, 729330));
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

export default Dogecoin;
