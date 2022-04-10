import {
  GET_ETH_ZKINPUT,
  GET_ETH_BALANCE,
  NEW_ETH_ACCOUNT,
  LOAD_ETH_ACCOUNT,
  GET_ETH_ADDRESS,
  GET_CONTRACT_INFO,
  GET_CLOSEST_HASH,
  TRANSACTION_SENT,
} from './ethActions';

const initialState = {
  input: '' as string,
  ethBalance: '' as string,
  keyfile: '' as string,
  ethAddress: '' as string,
  closestHash: '' as string,
  ethTransactionResult: '' as string,
  contract: {contract_address: '' as string, abi: '' as string},
};

function ethReducer(state = initialState, action: any) {
  switch (action.type) {
    case GET_ETH_ZKINPUT:
      return {...state, input: action.payload};
    case GET_CONTRACT_INFO:
      return {...state, contract: action.payload};
    case GET_ETH_BALANCE:
      return {...state, ethBalance: action.payload};
    case NEW_ETH_ACCOUNT:
      return {...state, keyfile: action.payload};
    case LOAD_ETH_ACCOUNT:
      if (action.payload === 'account already exists') {
        return {...state};
      }
      return {...state, keyfile: action.payload};
    case GET_ETH_ADDRESS:
      console.log(action.payload);
      return {...state, ethAddress: action.payload};
    case GET_CLOSEST_HASH:
      return {...state, closestHash: action.payload};
    case TRANSACTION_SENT:
      return {...state, ethTransactionResult: action.payload};
    default:
      return state;
  }
}

export default ethReducer;
