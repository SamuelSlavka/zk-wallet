/* eslint-disable prettier/prettier */
import { GET_BTC_HEADERS, SET_BTC_CREDENTIALS, GET_BTC_TRANSACTIONS, GET_BTC_CLOSEST_HASH } from './btcActions';
import '../btcModels';
import { BtcHeader, BtcTransaction } from '../btcModels';

const initialState = {
    btcBalance: 0 as number,
    btcHeaders: [] as BtcHeader[],
    btcValidHeaders: {},
    btcTransactions: [] as BtcTransaction[],
    btcCreadentails: { address: '' as string, pk: '' as string },
    btcClosestHash: { hash: 0 as number, height: 0 as number },
};

function btcReducer(state = initialState, action: any) {
    switch (action.type) {
        case GET_BTC_TRANSACTIONS:
            const transactions = action.payload.data.map(
                function (transaction: any) {
                    return new BtcTransaction(
                        transaction.transaction_hash,
                        transaction.value,
                        transaction.block_id,
                        transaction.transaction_id,
                        transaction.spending_transaction_hash,
                        transaction.spending_block_id,
                    );
                });
            // if incomming transaction was spend dont add to balance
            const balance = transactions.reduce(function (previousValue : any, currentValue : any): number {
                return previousValue + currentValue.spending_block_id ? 0 : currentValue.value;
            }, 0);

            return { ...state, btcTransactions: transactions, btcBalance: balance };
        case SET_BTC_CREDENTIALS:
            return { ...state, btcCreadentails: action.payload };
        case GET_BTC_CLOSEST_HASH:
            console.log(action.payload);
            return { ...state, btcClosestHash: action.payload };
        case GET_BTC_HEADERS:
            const newHeaders: BtcHeader[] = [];
            action.payload.data.forEach((header: any) => {
                newHeaders.push(
                    new BtcHeader(
                        header.id,
                        header.bits,
                        header.version_hex,
                        header.merkle_root,
                        header.time,
                        header.bits,
                        header.nonce,
                        header.hash,
                    ),
                );
            });
            return { ...state, btcHeaders: newHeaders };
        default:
            return state;
    }
}

export default btcReducer;
