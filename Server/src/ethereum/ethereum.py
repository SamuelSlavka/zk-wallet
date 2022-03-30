""" Blockchain interaction """
import json, logging
from web3 import Web3
from web3.middleware import geth_poa_middleware

from web3.gas_strategies.time_based import medium_gas_price_strategy

from src.ethereum.utils import HexJsonEncoder
from src.ethereum.grapQL import getBlockHeaders
from src.ethereum.eth_header_manipulation import BlockHeader

def init_eth_with_pk(privatekey, provider):
    """ Initialize blockchain connection """
    web3 = Web3(Web3.HTTPProvider(provider))
    # ONLY IN RINKEBY!!
    #web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    acc = web3.eth.account.privateKeyToAccount(privatekey)
    web3.eth.default_account = acc.address
    web3.eth.set_gas_price_strategy(medium_gas_price_strategy)
    
    return web3

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

def create_proof(blockNumber):
    """ create proof for block number """
    try:
        headers = getBlockHeaders(0,blockNumber)
        hashes = []
        for header in headers['blocks']:
            hashes.append(BlockHeader(header).hash)
        return json.dumps(hashes)
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}
