import axios from 'axios';
import {NativeModules} from 'react-native';

import {BASE_URL} from '../config';

export const getBalance = () => {
  return async (dispatch: any) => {
    NativeModules.CommunicationNative.getBalance((str: any) => {
      dispatch({
        type: GET_ETH_BALANCE,
        payload: str,
      });
    });
  };
};

export const getAddress = () => {
  return async (dispatch: any) => {
    NativeModules.CommunicationNative.getAddress((str: any) => {
      dispatch({
        type: GET_ETH_ADDRESS,
        payload: str,
      });
    });
  };
};

export const newAccount = (password: string, exportPassword: string) => {
  return async (dispatch: any) => {
    NativeModules.CommunicationNative.setupAccount(
      password,
      exportPassword,
      (str: any) => {
        dispatch({
          type: NEW_ETH_ACCOUNT,
          payload: str,
        });
      },
    );
  };
};

export const loadAccount = (
  setupResult: string,
  password: string,
  exportPassword: string,
) => {
  return async (dispatch: any) => {
    NativeModules.CommunicationNative.loadAccount(
      setupResult,
      exportPassword,
      password,
      (str: any) => {
        dispatch({
          type: LOAD_ETH_ACCOUNT,
          payload: str,
        });
      },
    );
  };
};

export const getZkInput = () => {
  return async (dispatch: any) => {
    axios
      .get(`${BASE_URL}/btc`)
      .then(function (response) {
        if (response.data) {
          dispatch({
            type: GET_ETH_ZKINPUT,
            payload: response.data,
          });
        } else {
          console.log('Unable to fetch data from the API BASE URL!');
        }
      })
      .catch(function (error: any) {
        console.warn(error);
      });
  };
};

export const GET_ETH_ZKINPUT = 'GET_ETH_ZKINPUT';
export const GET_ETH_BALANCE = 'GET_ETH_BALANCE';
export const NEW_ETH_ACCOUNT = 'NEW_ETH_ACCOUNT';
export const LOAD_ETH_ACCOUNT = 'LOAD_ETH_ACCOUNT';
export const GET_ETH_ADDRESS = 'GET_ETH_ADDRESS';
