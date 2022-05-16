import {createStore, combineReducers, applyMiddleware} from 'redux';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {persistStore, persistReducer} from 'redux-persist';
import thunk from 'redux-thunk';

import ethReducer from './ethReducer';
import btcReducer from './btc/btcReducer';
import bchReducer from './bch/bchReducer';

// set up persistent data storage in redux
const persistEthConfig = {
  key: 'eth',
  storage: AsyncStorage,
  whitelist: ['keyfile', 'contract', 'closestHash'],
};

// for testing purposes use following whitelists
// const btcWhitelist = ['btcHeaders', 'btcCreadentails'];
// const bchWhitelist = ['bchHeaders', 'bchCreadentails'];

// in production use this whitlist
const btcWhitelist = [
  'btcHeaders',
  'btcCreadentails',
  'btcValidHeaders',
  'btcValidTransactions',
];
const bchWhitelist = [
  'bchHeaders',
  'bchCreadentails',
  'bchValidHeaders',
  'bchValidTransactions',
];

const persistBtcConfig = {
  key: 'btc',
  storage: AsyncStorage,
  whitelist: btcWhitelist,
};

const persistBchConfig = {
  key: 'bch',
  storage: AsyncStorage,
  whitelist: bchWhitelist,
};

const rootReducer = combineReducers({
  ethereumReducer: persistReducer(persistEthConfig, ethReducer),
  bitcoinReducer: persistReducer(persistBtcConfig, btcReducer),
  bitcoinCashReducer: persistReducer(persistBchConfig, bchReducer),
});

export const store = createStore(rootReducer, applyMiddleware(thunk));
export const persistor = persistStore(store);
export type RootState = ReturnType<typeof rootReducer>;
