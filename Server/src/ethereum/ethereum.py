""" Blockchain interaction """
import json, logging
from web3 import Web3
from web3.middleware import geth_poa_middleware

from web3.gas_strategies.time_based import medium_gas_price_strategy

from src.ethereum.utils import HexJsonEncoder

def init_eth_with_pk(privatekey, provider):
    """ Initialize blockchain connection """
    try:
        web3 = Web3(Web3.HTTPProvider(provider))
        # ONLY IN RINKEBY!!
        # web3.middleware_onion.inject(geth_poa_middleware, layer=0)

        acc = web3.eth.account.privateKeyToAccount(privatekey)
        web3.eth.default_account = acc.address
        web3.eth.set_gas_price_strategy(medium_gas_price_strategy)
        
        return web3
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error':'Error setting up web3'}


def get_last_transaction(web3):
    """ return last transaction form blockchain """
    try:
        transaction = web3.eth.get_transaction_by_block(web3.eth.blockNumber, 0)
        tx_dict = dict(transaction)
        tx_json = json.dumps(tx_dict, cls=HexJsonEncoder)
        return tx_json
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}
