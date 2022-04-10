/* eslint-disable prettier/prettier */
import { GET_BTC_HEADERS } from './btcActions';
import './btcModels';
import { BtcHeader } from './btcModels';

const initialState = {
    btcHeaders: [] as BtcHeader[],
    btcCreadentails: {address: '' as string, pk: '' as string},
};

function btcReducer(state = initialState, action: any) {
    switch (action.type) {
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
