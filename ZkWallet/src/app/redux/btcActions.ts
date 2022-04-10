/* eslint-disable prettier/prettier */
import axios from 'axios';
import { Payload } from './btcModels';
import { BTC_URL, BTC_TOKEN } from '../config';

const headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'X-Auth-Token': BTC_TOKEN,
}

export const getHeaderByHash = async (hash: number): Promise<any>  => {
    const promise = axios({
        method: 'post',
        url: BTC_URL,
        headers: headers,
        data: new Payload(0, [hash], 'getblock'),
    });

    const res = promise.then((response) => response.data);
    return res;
}

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
                    hashes.push(new Payload(element.id, [element.result], 'getblock'));
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
                            payload: res.data,
                        });
                    })
                    .catch(error => {
                        console.log(error);
                    });
            })
            .catch(error => {
                console.log(error);
            });
        return 'true';
    };
};

export const GET_BTC_HEADERS = 'GET_BTC_HEADERS';
