import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  View,
  NativeModules,
  Button,
  Alert,
} from 'react-native';

import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

import Bitcoin from './app/screens/Bitcoin';
import Ethereum from './app/screens/Ethereum';

const Home = () => {
  return (
    <SafeAreaView>
      <StatusBar barStyle={'light-content'} />
      <ScrollView contentInsetAdjustmentBehavior="automatic">
        <View>
          <Button
            title="button"
            onPress={() => {
              NativeModules.CommunicationNative.test('str', (str: any) => {
                Alert.alert(str);
              });
            }}
          />
          <NavigationContainer>
            <Stack.Navigator>
              <Stack.Screen name="Eth" component={Ethereum} />
              <Stack.Screen name="Btc" component={Bitcoin} />
            </Stack.Navigator>
          </NavigationContainer>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

export default Home;
