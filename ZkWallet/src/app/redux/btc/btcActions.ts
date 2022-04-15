/* eslint-disable prettier/prettier */
import axios from 'axios';
import { NativeModules } from 'react-native';
import { BTC_TOKEN, BLOCKCHAIR_URL, BTC_URL } from '../../config';
import { Payload, ClosestHashParams } from '../btcModels';

const headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Auth-Token': BTC_TOKEN,
    'x-api-key': BTC_TOKEN,
};

// return closest hash to given height from smart contract
export const getClosestHash = ( params: ClosestHashParams )  => {
    return async (dispatch: any) => {
        NativeModules.CommunicationNative.getClosestHash(
            params.blockchainId,
            params.password,
            params.contractAddress,
            params.abi,
            params.target,
            (hash: any, height: any) => {
                dispatch({
                    type: GET_BTC_CLOSEST_HASH,
                    payload: { hash: hash, height: height, target: params.target },
                });
            },
        );
    };
};

// catch up to given height with headers
export const catchUp = ( start: number, end: number )  => {
    console.log(start, end);
};

// save credentials to prenament storage
export const setCredentials = (address: string, pk: string) => {
    return async (dispatch: any) => {
        dispatch({
            type: SET_BTC_CREDENTIALS,
            payload: { address, pk },
        });
    };
};

// get all outgoing transactions from an address
export const getBalanceSummary = (address: string) => {
    return async (dispatch: any) => {
        axios({
            method: 'get',
            url: BLOCKCHAIR_URL + '/bitcoin/outputs?s=value(asc)&q=recipient(' + address + ')#f=transaction_hash,value,recipient,block_id,transaction_id,index,spending_transaction_hash,is_spent,time',
            headers: headers,
        })
            .then(response => {
                dispatch({
                    type: GET_BTC_TRANSACTIONS,
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
    const blockNumbers: Payload[] = [];
    for (let i = begining; i < end; i++) {
        blockNumbers.push(new Payload(i, [i], 'getblockhash'));
    }
    return async (dispatch: any) => {
        // get header hashes by their numbers
        axios({
            method: 'post',
            url: BTC_URL,
            headers: headers,
            data: blockNumbers,
        })
            .then(response => {
                // get full headers by their hashes
                const hashes: Payload[] = [];
                response.data.forEach((element: any) => {
                    hashes.push(new Payload(element.id, [element.result], 'getblockheader'));
                });
                axios({
                    method: 'post',
                    url: BTC_URL,
                    headers: headers,
                    data: hashes,
                })
                    .then(res => {
                        dispatch({
                            type: GET_BTC_HEADERS,
                            payload: res,
                        });
                    })
                    .catch(error => {
                        console.log(error);
                    });
            })
            .catch(error => {
                console.log(error);
            });
    };
};

export const GET_BTC_CLOSEST_HASH = 'GET_BTC_CLOSEST_HASH';
export const GET_BTC_TRANSACTIONS = 'GET_BTC_TRANSACTIONS';
export const GET_BTC_HEADERS = 'GET_BTC_HEADERS';
export const SET_BTC_CREDENTIALS = 'SET_BTC_CREDENTIALS';

