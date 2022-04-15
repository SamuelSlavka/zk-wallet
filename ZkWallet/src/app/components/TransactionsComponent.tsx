import React from 'react';
import {Text, SafeAreaView, StyleSheet, View} from 'react-native';
import {BtcTransaction, ClosestHashParams} from '../redux/btcModels';
import {useSelector, useDispatch} from 'react-redux';
import {RootState} from '../redux/store';

import ButtonComponent from './ButtonComponent';

type Props = {
  transactions: BtcTransaction[];
  catchUp: Function;
  getHash: Function;
  closestHash: {hash: string; height: number};
};

const TransactionsComponent = (props: Props) => {
  const dispatch = useDispatch();
  const {contract} = useSelector((state: RootState) => state.ethereumReducer);

  // return closest hash ti height
  const getHash = (password: string, height: number) =>
    dispatch(
      props.getHash(
        new ClosestHashParams(
          0,
          password,
          contract.contract_address,
          JSON.stringify(contract.abi),
          height,
        ),
      ),
    );

  // download and validate all headers between numbers
  const catchUp = (start: number, end: number) =>
    dispatch(props.catchUp(start, end));

  const listItems = props.transactions.map((transaction: BtcTransaction) => {
    const validated = transaction.validated?.toString();
    const spent = transaction.spending_tx_hash ? 'true' : 'false';
    const catchUpLength = props.closestHash.hash
      ? transaction.block_height - props.closestHash.height
      : transaction.block_height;

    return (
      <View style={styles.container} key={transaction.tx_hash}>
        <Text key={'1'}>transaction: {transaction.tx_hash}</Text>
        <Text key={'2'}>in block: {transaction.block_height}</Text>
        <Text key={'3'}>
          valid: {validated} spent: {spent}
        </Text>
        <ButtonComponent
          key={'6'}
          title="Get Closest Header"
          callback={() => getHash('password', transaction.block_height)}
        />
        <ButtonComponent
          key={'4'}
          title="Catch up"
          contents={catchUpLength.toString() + ' blocks'}
          callback={() =>
            catchUp(props.closestHash.height, transaction.block_height)
          }
        />
        <ButtonComponent key={'5'} title="Validate" callback={() => {}} />
      </View>
    );
  });

  return <SafeAreaView>{listItems}</SafeAreaView>;
};

const styles = StyleSheet.create({
  container: {
    margin: 5,
    padding: 5,
    borderWidth: 2,
    borderColor: '#20232a',
    borderRadius: 4,
  },
});

export default TransactionsComponent;
