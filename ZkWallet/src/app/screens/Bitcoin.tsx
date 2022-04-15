import React, {useEffect} from 'react';
import {Text, SafeAreaView, StyleSheet, ScrollView} from 'react-native';
import {useSelector, useDispatch} from 'react-redux';
import {RootState} from '../redux/store';

import {getClosestHash} from '../redux/btc/btcActions';
import {ClosestHashParams} from '../redux/btcModels';

import TransactionsComponent from '../components/TransactionsComponent';
import ButtonComponent from '../components/ButtonComponent';

import {
  getBtcHeaders,
  getBalanceSummary,
  catchUp,
} from '../redux/btc/btcActions';

// import {getInfo} from '../redux/ethActions';

const address = '37Q13UiqZz4mkyuumyzKifSdApa5Bk3TV5';

const Bitcoin = () => {
  const {
    btcHeaders,
    btcCreadentails,
    btcTransactions,
    btcBalance,
    btcClosestHash,
  } = useSelector((state: RootState) => state.bitcoinReducer);

  const dispatch = useDispatch();

  const refreshData = () => {
    dispatch(getBalanceSummary(address));
    // setup creadentials in prenament storage
    btcCreadentails.address = address;
    console.log(btcCreadentails.address);
  };

  useEffect(() => {
    refreshData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <SafeAreaView>
      <ScrollView>
        <Text style={styles.header}>Last stored header:</Text>
        <Text>{btcHeaders?.[btcHeaders.length - 1]?.hash}</Text>
        <Text style={styles.header}>Closest hash:</Text>
        <Text>{btcClosestHash.hash}</Text>
        <Text style={styles.header}>Your address:</Text>
        <Text>{btcCreadentails.address}</Text>
        <Text style={styles.header}>Your balance:</Text>
        <Text>{btcBalance}</Text>
        <Text style={styles.header}>Your txses:</Text>
        <TransactionsComponent
          transactions={btcTransactions}
          getHash={(input: ClosestHashParams) => {
            getClosestHash(input);
          }}
          catchUp={(start: number, end: number) => {
            catchUp(start, end);
          }}
          closestHash={btcClosestHash}
        />
        <ButtonComponent
          title="Refresh"
          callback={() => {
            refreshData();
          }}
        />
        <ButtonComponent
          title="Get headers"
          callback={() => {
            dispatch(getBtcHeaders(4, 6));
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
