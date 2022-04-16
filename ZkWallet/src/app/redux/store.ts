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

const persistBtcConfig = {
  key: 'btc',
  storage: AsyncStorage,
  whitelist: [
    'btcHeaders',
    'btcCreadentails',
    'btcValidHeaders',
    'btcValidTransactions',
  ],
};

const persistBchConfig = {
  key: 'bch',
  storage: AsyncStorage,
  whitelist: [
    'bchHeaders',
    'bchCreadentails',
    'bchValidHeaders',
    'bchValidTransactions',
  ],
};

const rootReducer = combineReducers({
  ethereumReducer: persistReducer(persistEthConfig, ethReducer),
  bitcoinReducer: persistReducer(persistBtcConfig, btcReducer),
  bitcoinCashReducer: persistReducer(persistBchConfig, bchReducer),
});

export const store = createStore(rootReducer, applyMiddleware(thunk));
export const persistor = persistStore(store);
export type RootState = ReturnType<typeof rootReducer>;
