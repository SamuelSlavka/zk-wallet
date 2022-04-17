import {
  GET_BCH_HEADERS,
  SET_BCH_CREDENTIALS,
  GET_BCH_TRANSACTIONS,
  GET_BCH_CLOSEST_HASH,
  SET_BCH_VALID_TRANSACTION,
} from './bchActions';
import {
  BtcHeader,
  BtcTransaction,
  ValidatedHeader,
  ValidatedTransaction,
} from '../btcModels';
import '../../../../shim';

const initialState = {
  bchBalance: 0 as number,
  bchHeaders: [] as BtcHeader[],
  // mapping of validated headers
  bchValidHeaders: {} as ValidatedHeader,
  bchTransactions: [] as BtcTransaction[],
  bchValidTransactions: {} as ValidatedTransaction,
  bchCreadentails: {address: '' as string, pk: '' as string},
  bchClosestHash: {hash: '' as string, height: 0 as number},
};

function bchReducer(state = initialState, action: any) {
  switch (action.type) {
    case GET_BCH_TRANSACTIONS:
      const transactions = action.payload.data.map(function (transaction: any) {
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
      const balance = transactions.reduce(function (
        previousValue: any,
        currentValue: any,
      ): number {
        return previousValue + currentValue.spending_block_id
          ? 0
          : currentValue.value;
      },
      0);
      return {...state, bchTransactions: transactions, bchBalance: balance};

    case SET_BCH_CREDENTIALS:
      return {...state, bchCreadentails: action.payload};

    case SET_BCH_VALID_TRANSACTION:
      const validTramsactions = {
        ...state.bchValidTransactions,
        [action.payload.hash]: action.payload.status,
      };
      return {...state, bchValidTransactions: validTramsactions};

    case GET_BCH_CLOSEST_HASH:
      const validHeaders = {
        ...state.bchValidHeaders,
        [action.payload.height]: BigInt(action.payload.hash)
          .toString(16)
          .padStart(64, '0'),
      };
      // set it as closest hash
      var closestHash = {
        hash: BigInt(action.payload.hash).toString(16),
        height: parseInt(action.payload.height, 10),
      };
      // check if there is another validated header closer
      for (var i = action.payload.target; i > action.payload.height; i--) {
        if (validHeaders[i]) {
          closestHash = {
            hash: validHeaders[i],
            height: i,
          };
          break;
        }
      }
      return {
        ...state,
        bchClosestHash: closestHash,
        bchValidHeaders: validHeaders,
      };

    case GET_BCH_HEADERS:
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
        const prevHash =
          state.bchValidHeaders[parseInt(newHeader.height, 10) - 1];
        if (prevHash && newHeader.checkValidity(prevHash)) {
          const hash1 = newHeader.getHash();
          state.bchValidHeaders[parseInt(newHeader.height, 10)] = hash1;
        }
        newHeaders.push(newHeader);
      });
      return {
        ...state,
        bchHeaders: newHeaders,
        bchValidHeaders: state.bchValidHeaders,
      };
    default:
      return state;
  }
}

export default bchReducer;
