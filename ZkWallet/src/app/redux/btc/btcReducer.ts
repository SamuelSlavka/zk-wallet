/* eslint-disable prettier/prettier */
import { GET_BTC_HEADERS, SET_BTC_CREDENTIALS, GET_BTC_TRANSACTIONS, GET_BTC_CLOSEST_HASH } from './btcActions';
import { BtcHeader, BtcTransaction, ValidatedHeader } from '../btcModels';


const initialState = {
    btcBalance: 0 as number,
    btcHeaders: [] as BtcHeader[],
    // mapping of validated headers
    btcValidHeaders: {} as ValidatedHeader,
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
            const validHeaders = {
                    ...state.btcValidHeaders,
                    [action.payload.height]: BigInt(action.payload.hash).toString(16),
                };
            return { ...state, btcClosestHash: action.payload, btcValidHeaders: validHeaders };
        case GET_BTC_HEADERS:
            const newHeaders: BtcHeader[] = [];
            action.payload.data.forEach((header: any) => {
                // version+previous_block_hash + merkle_root+timestamp+bits+nonce
                const newHeader = new BtcHeader(
                    header.result.versionHex,
                    header.result.previousblockhash,
                    header.result.merkleroot,
                    header.result.time,
                    header.result.bits,
                    header.result.nonce,

                    header.result.height,
                    header.result.hash,
                );
                // If new header has previous already among valid headers it is assumend as valid
                // we store only calculated header to check for stuff
                const prevHash = state.btcValidHeaders[parseInt(newHeader.height, 10) - 1];
                if (prevHash && newHeader.checkValidity(prevHash)) {
                    console.log('got here')
                    const hash1 = newHeader.getHash();
                    state.btcValidHeaders[parseInt(newHeader.height, 10)] = hash1;
                }
                newHeaders.push(newHeader);
            });
            console.log(state.btcValidHeaders);
            return { ...state, btcHeaders: newHeaders, btcValidHeaders: state.btcValidHeaders};
        default:
            return state;
    }
}

export default btcReducer;
