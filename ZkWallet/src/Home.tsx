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
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

export default Home;
