import * as React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {NavigationContainer} from '@react-navigation/native';

import Ethereum from './app/screens/Ethereum';
import Bitcoin from './app/screens/Bitcoin';

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={{
          tabBarIconStyle: {display: 'none'},
          tabBarLabelStyle: {
            fontWeight: '700',
            fontSize: 20,
          },
          tabBarLabelPosition: 'beside-icon',
        }}>
        <Tab.Screen name="Eth" component={Ethereum} />
        <Tab.Screen name="Btc" component={Bitcoin} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}
