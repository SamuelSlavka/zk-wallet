import * as React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {NavigationContainer} from '@react-navigation/native';

import Ethereum from '../screens/Ethereum';
import Bitcoin from '../screens/Bitcoin';

const Tab = createBottomTabNavigator();

const RootNavigator = () => {
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
};

export default RootNavigator;
