import React, {useEffect} from 'react';
import {Text, SafeAreaView, StyleSheet, ScrollView} from 'react-native';
import {useSelector, useDispatch} from 'react-redux';
import {RootState} from '../redux/store';

import TransactionsComponent from '../components/TransactionsComponent';
import ButtonComponent from '../components/ButtonComponent';

import {
  getBchHeaders,
  getBalanceSummary,
  getClosestHash,
  validateTransaction,
} from '../redux/bch/bchActions';

const address = 'qrn29uc480r8ra8yvfyuzr35dhrs776hgye0fqpnem';

const BitcoinCash = () => {
  const {
    bchHeaders,
    bchCreadentails,
    bchTransactions,
    bchBalance,
    bchClosestHash,
    bchValidTransactions,
  } = useSelector((state: RootState) => state.bitcoinCashReducer);

  const dispatch = useDispatch();

  useEffect(() => {
    // setup creadentials in prenament storage
    bchCreadentails.address = address;
    console.log(bchCreadentails.address);
    dispatch(getBalanceSummary(address));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <SafeAreaView>
      <ScrollView>
        <Text style={styles.header}>Last stored header:</Text>
        <Text>{bchHeaders?.[bchHeaders.length - 1]?.hash}</Text>
        <Text style={styles.header}>Closest hash:</Text>
        <Text>{bchClosestHash.hash}</Text>
        <Text style={styles.header}>Your address:</Text>
        <Text>{bchCreadentails.address}</Text>
        <Text style={styles.header}>Your balance:</Text>
        <Text>{bchBalance}</Text>
        <Text style={styles.header}>Your txses:</Text>
        <TransactionsComponent
          transactions={bchTransactions}
          getClosestHash={getClosestHash}
          catchUp={getBchHeaders}
          validateTransaction={validateTransaction}
          closestHash={bchClosestHash}
          validTransactions={bchValidTransactions}
          merkleRoot={
            bchHeaders.find(
              header => parseInt(header.height, 10) === bchClosestHash.height,
            )?.merkle_root ?? ''
          }
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
            dispatch(getBchHeaders(4, 6));
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
