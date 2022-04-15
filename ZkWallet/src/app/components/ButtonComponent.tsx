import React from 'react';
import {TouchableHighlight, StyleSheet, Text} from 'react-native';

type Props = {
  title: string;
  contents?: string;
  callback: Function;
};

const ButtonComponent = (props: Props) => {
  const textContents =
    props?.title + (props?.contents ? '\n' + props?.contents : '');

  return (
    <TouchableHighlight
      underlayColor="#008ae6"
      style={styles.buttonContainer}
      onPress={() => {
        props.callback();
      }}>
      <Text style={styles.buttonText}>{textContents}</Text>
    </TouchableHighlight>
  );
};

const styles = StyleSheet.create({
  buttonContainer: {
    marginTop: 4,
    borderRadius: 4,
    backgroundColor: '#6699ff',
  },
  buttonText: {
    margin: 8,
    fontSize: 16,
    color: 'white',
    textAlign: 'center',
  },
});

export default ButtonComponent;
