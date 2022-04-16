import React from 'react';
import {Text, SafeAreaView, StyleSheet, View, Alert} from 'react-native';
import {BtcTransaction, ClosestHashParams} from '../redux/btcModels';
import {useSelector, useDispatch} from 'react-redux';
import {RootState} from '../redux/store';

import ButtonComponent from './ButtonComponent';

type Props = {
  transactions: BtcTransaction[];
  catchUp: (start: number, end: number) => void;
  getClosestHash: (input: ClosestHashParams) => void;
  validateTransaction: (transactionHash: string, blockHeight: number) => void;
  closestHash: {hash: string; height: number};
};

const TransactionsComponent = (props: Props) => {
  const dispatch = useDispatch();
  const {contract} = useSelector((state: RootState) => state.ethereumReducer);

  // return closest hash ti height
  const getHashparams = (password: string, height: number) =>
    new ClosestHashParams(
      0,
      password,
      contract.contract_address,
      JSON.stringify(contract.abi),
      height,
    );

  const getClosestHash = (password: string, height: number) => {
    dispatch(props.getClosestHash(getHashparams(password, height)));
  };

  const showAlert = (numOfHeaders: number) => {
    Alert.alert(
      'Error: Too many headers in sync',
      `You are bout to download ${numOfHeaders} headers.\nCan't sync more than 200 headers.\nTry getting closer hash form SC`,
      [
        {
          text: 'Ok',
        },
      ],
      {cancelable: true},
    );
  };

  const listItems = props.transactions.map((transaction: BtcTransaction) => {
    const validated = transaction.validated?.toString();
    const spent = transaction.spending_tx_hash ? 'true' : 'false';
    const catchUpLength = props.closestHash.hash
      ? transaction.block_height - props.closestHash.height
      : transaction.block_height;

    const action = catchUpLength ? (
      <ButtonComponent
        key={'5'}
        title="Catch up"
        contents={catchUpLength.toString() + ' blocks'}
        callback={() => {
          console.log(catchUpLength);
          if (catchUpLength > 200) {
            showAlert(catchUpLength);
          } else {
            dispatch(
              props.catchUp(
                props.closestHash.height,
                transaction.block_height + 1,
              ),
            );
          }
        }}
      />
    ) : (
      <ButtonComponent
        key={'5'}
        title="Validate"
        callback={() =>
          dispatch(
            props.validateTransaction(
              transaction.tx_hash,
              transaction.block_height,
            ),
          )
        }
      />
    );
    return (
      <View style={styles.container} key={transaction.tx_hash}>
        <Text key={'1'}>transaction: {transaction.tx_hash}</Text>
        <Text key={'2'}>in block: {transaction.block_height}</Text>
        <Text key={'3'}>
          valid: {validated} spent: {spent}
        </Text>
        <ButtonComponent
          key={'4'}
          title="Get closest hash"
          callback={() => getClosestHash('password', transaction.block_height)}
        />
        {action}
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
