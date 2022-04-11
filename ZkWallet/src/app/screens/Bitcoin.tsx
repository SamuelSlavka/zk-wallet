import React, {useEffect} from 'react';
import {Text, SafeAreaView, Button} from 'react-native';
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
  const {btcHeaders, btcCreadentails} = useSelector(
    (state: RootState) => state.bitcoinReducer,
  );
  const {closestHash, contract} = useSelector(
    (state: RootState) => state.ethereumReducer,
  );

  const dispatch = useDispatch();
  const refreshData = () => {
    dispatch(getInfo());
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
    if (btcCreadentails.address === '') {
      try {
        const keyPair = new BitcoinJs.ECPair.fromWIF(
          'KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn',
        );
        console.log(keyPair.getPublicKeyBuffer().toString('hex'));
        console.log(keyPair.getAddress());
        btcCreadentails.address = keyPair.getAddress();
      } catch (error) {
        console.error(error);
      }
    }

    refreshData();
    dispatch(getBtcHeaders(0, 3));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <SafeAreaView>
      <Text>Last stored header:</Text>
      <Text>{btcHeaders?.[btcHeaders.length - 1]?.hash}</Text>
      <Text>Closest hash:</Text>
      <Text>{closestHash}</Text>
      <Text>Contract address:</Text>
      <Text>{contract.contract_address}</Text>
      <Text>Your address:</Text>
      <Text>{btcCreadentails.address}</Text>
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
      <Button
        title="Get summary"
        onPress={() => {
          dispatch(getBalanceSummary(address));
        }}
      />
    </SafeAreaView>
  );
};

export default Bitcoin;
