/**
 * @format
 */

if (typeof BigInt === 'undefined') global.BigInt = require('big-integer');
import './shim';
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
