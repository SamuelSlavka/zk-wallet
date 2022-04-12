/* eslint-disable prettier/prettier */
import { GET_DOGE_HEADERS, SET_DOGE_CREDENTIALS, GET_DOGE_TRANSACTIONS, GET_DOGE_CLOSEST_HASH } from './dogeActions';
import './btcModels';
import { BtcHeader, BtcTransaction } from './btcModels';

const initialState = {
    dogeBalance: 0 as number,
    dogeHeaders: [] as BtcHeader[],
    dogeTransactions: [] as BtcTransaction[],
    dogeCreadentails: { address: '' as string, pk: '' as string },
    dogeClosestHash: '' as string,
};

function dogeReducer(state = initialState, action: any) {
    switch (action.type) {
        case GET_DOGE_TRANSACTIONS:
            const transactions = action.payload.txs.map(
                function (transaction: any) {
                    return new BtcTransaction(
                        transaction.hash,
                        transaction.total,
                        transaction.block_hash,
                        transaction.block_height,
                        transaction.block_index
                        );
                });
            return { ...state, dogeTransactions: transactions, dogeBalance: action.payload.final_balance };
        case SET_DOGE_CREDENTIALS:
            return { ...state, dogeCreadentails: action.payload };
        case GET_DOGE_CLOSEST_HASH:
            return { ...state, dogeClosestHash: action.payload };
        case GET_DOGE_HEADERS:
            const newHeaders: BtcHeader[] = [];
            action.payload.forEach((header: any) => {
                const result = header.result;
                newHeaders.push(
                    new BtcHeader(
                        result.height,
                        result.bits,
                        result.previousblockhash,
                        result.versionHex,
                        result.merkleroot,
                        result.time,
                        result.bits,
                        result.nonce,
                        result.hash,
                    ),
                );
            });
            return { ...state, dogeHeaders: newHeaders };
        default:
            return state;
    }
}

export default dogeReducer;
