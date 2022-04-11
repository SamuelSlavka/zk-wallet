/* eslint-disable prettier/prettier */
import { GET_BTC_HEADERS, SET_BTC_CREDENTIALS, GET_BTC_TRANSACTIONS } from './btcActions';
import './btcModels';
import { BtcHeader, BtcTransaction } from './btcModels';

const initialState = {
    btcHeaders: [] as BtcHeader[],
    btcTransactions: [] as BtcTransaction[],
    btcCreadentails: { address: '' as string, pk: '' as string },
};

function btcReducer(state = initialState, action: any) {
    switch (action.type) {
        case GET_BTC_TRANSACTIONS:
            const transactions = action.payload.txs.map(
                function (transaction: any) {
                    return new BtcTransaction(transaction.hash, transaction.result, transaction.block_height);
                });
            return { ...state, btcTransactions: transactions };
        case SET_BTC_CREDENTIALS:
            return { ...state, btcCreadentails: action.payload };
        case GET_BTC_HEADERS:
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
            return { ...state, btcHeaders: newHeaders };
        default:
            return state;
    }
}

export default btcReducer;
