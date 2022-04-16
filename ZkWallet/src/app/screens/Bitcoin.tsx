import React, {useEffect} from 'react';
import {Text, SafeAreaView, StyleSheet, ScrollView} from 'react-native';
import {useSelector, useDispatch} from 'react-redux';
import {RootState} from '../redux/store';

import TransactionsComponent from '../components/TransactionsComponent';
import ButtonComponent from '../components/ButtonComponent';

import {
  getBtcHeaders,
  getBalanceSummary,
  getClosestHash,
  validateTransaction,
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

  useEffect(() => {
    // setup creadentials in prenament storage
    btcCreadentails.address = address;
    console.log(btcCreadentails.address);
    dispatch(getBalanceSummary(address));
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
          getClosestHash={getClosestHash}
          catchUp={getBtcHeaders}
          validateTransaction={validateTransaction}
          closestHash={btcClosestHash}
        />
        <ButtonComponent
          title="Refresh"
          callback={() => {
            dispatch(getBalanceSummary(address));
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
