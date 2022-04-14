/* eslint-disable prettier/prettier */
import axios from 'axios';
import {NativeModules} from 'react-native';
import { BTC_TOKEN, BLOCKCHAIR_URL } from '../../config';

const headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Auth-Token': BTC_TOKEN,
};

export const getClosestHash = (
    blockchainId: number,
    password: string,
    contractAddress: string,
    abi: string,
    target: number,
  ) => {
    return async (dispatch: any) => {
      NativeModules.CommunicationNative.getClosestHash(
        blockchainId,
        password,
        contractAddress,
        abi,
        target,
        (hash: any, height: any) => {
          dispatch({
            type: GET_BCH_CLOSEST_HASH,
            payload: {hash: hash, height: height},
          });
        },
      );
    };
  };

export const setCredentials = (address: string, pk: string) => {
    return async (dispatch: any) => {
        dispatch({
            type: SET_BCH_CREDENTIALS,
            payload: {address, pk},
        });
    };
};

export const getBalanceSummary = (address: string)  => {
    return async (dispatch: any) => {
        axios({
            method: 'get',
            url: BLOCKCHAIR_URL + '/bitcoin-cash/outputs?s=value(desc)&q=recipient(' + address + ')#f=transaction_hash,value,recipient,block_id,transaction_id,index,spending_transaction_hash,is_spent,time',
            headers: headers,
        })
        .then(response => {
            dispatch({
                type: GET_BCH_TRANSACTIONS,
                payload: response.data,
            });
        })
        .catch(error => {
            console.log(error);
        });
    };
};

// finds set of headers by theirs height
export const getBtcHeaders = (begining: number, end: number) => {
    return async (dispatch: any) => {
        // get header hashes by their numbers
        axios({
            method: 'get',
            url: BLOCKCHAIR_URL + '/bitcoin-cash/blocks?s=id(desc)&q=id(' + begining + '..' + end + ')#f=id,hash,time,transaction_count,version_hex,merkle_root,bits,nonce,difficulty',
            headers: headers,
        })
        .then(response => {
            dispatch({
                type: GET_BCH_HEADERS,
                payload: response.data,
            });
        })
        .catch(error => {
            console.log(error);
        });
        return 'true';
    };
};

export const GET_BCH_CLOSEST_HASH = 'GET_BCH_CLOSEST_HASH';
export const GET_BCH_TRANSACTIONS = 'GET_BCH_TRANSACTIONS';
export const GET_BCH_HEADERS = 'GET_BCH_HEADERS';
export const SET_BCH_CREDENTIALS = 'SET_BCH_CREDENTIALS';

