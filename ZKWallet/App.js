/**
 * Main RN file
 *
 * @format
 * @flow strict-local
 */

import React, {useState, useEffect} from 'react';
import type {Node} from 'react';
import nodejs from 'nodejs-mobile-react-native';
import {Colors} from 'react-native/Libraries/NewAppScreen';
import {
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  Button,
} from 'react-native';

const App: () => Node = () => {
  const [mounted, setMounted] = useState(false);
  const [message, setMesage] = useState('init');

  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  if (mounted) {
    nodejs.start('main.js');

    nodejs.channel.addListener(
      'message',
      msg => {
        //setMesage(msg);
        console.warn(JSON.stringify(msg));
      },
      this,
    );
  }

  useEffect(() => {
    setMounted(true);
  }, []);

  return (
    <SafeAreaView style={backgroundStyle}>
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <View style={styles.sectionContainer}>
          <Text style={[styles.sectionTitle]}>ZKWallet</Text>
          <Text style={[styles.sectionDescription]}>{message}</Text>
        </View>
        <Button
          title="Message Node"
          onPress={() => nodejs.channel.send('A message!')}
        />
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
