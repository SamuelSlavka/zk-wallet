import {createStore, combineReducers, applyMiddleware} from 'redux';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {persistStore, persistReducer} from 'redux-persist';
import thunk from 'redux-thunk';

import ethReducer from './ethReducer';
import btcReducer from './btc/btcReducer';
import bchReducer from './bch/bchReducer';

const persistEthConfig = {
  key: 'root',
  storage: AsyncStorage,
  whitelist: ['keyfile', 'contract', 'closestHash'],
};

const persistBtcConfig = {
  key: 'root',
  storage: AsyncStorage,
  whitelist: ['btcHeaders', 'btcCreadentails'],
};

const rootReducer = combineReducers({
  ethereumReducer: persistReducer(persistEthConfig, ethReducer),
  bitcoinReducer: persistReducer(persistBtcConfig, btcReducer),
  bitcoinCashReducer: bchReducer,
});

export const store = createStore(rootReducer, applyMiddleware(thunk));
export const persistor = persistStore(store);
export type RootState = ReturnType<typeof rootReducer>;
