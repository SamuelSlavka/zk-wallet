import * as React from 'react';
import {Provider} from 'react-redux';
import RootNavigator from './src/app/navigation/RootNavigator';
import {PersistGate} from 'redux-persist/integration/react';

import {store, persistor} from './src/app/redux/store';

export default function App() {
  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <RootNavigator />
      </PersistGate>
    </Provider>
  );
}
