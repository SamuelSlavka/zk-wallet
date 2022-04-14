/* eslint-disable prettier/prettier */
import { GET_BCH_HEADERS, SET_BCH_CREDENTIALS, GET_BCH_TRANSACTIONS, GET_BCH_CLOSEST_HASH } from './bchActions';
import '../btcModels';
import { BtcHeader, BtcTransaction } from '../btcModels';

const initialState = {
    bchBalance: 0 as number,
    bchHeaders: [] as BtcHeader[],
    bchTransactions: [] as BtcTransaction[],
    bchCreadentails: { address: '' as string, pk: '' as string },
    bchClosestHash: { hash: 0 as number, height: 0 as number },
};

function bchReducer(state = initialState, action: any) {
    switch (action.type) {
        case GET_BCH_TRANSACTIONS:
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
            return { ...state, bchTransactions: transactions, bchBalance: balance };
        case SET_BCH_CREDENTIALS:
            return { ...state, bchCreadentails: action.payload };
        case GET_BCH_CLOSEST_HASH:
            return { ...state, bchClosestHash: action.payload };
        case GET_BCH_HEADERS:
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
            return { ...state, bchHeaders: newHeaders };
        default:
            return state;
    }
}

export default bchReducer;
