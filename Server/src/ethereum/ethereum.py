""" Blockchain interaction """
import json
from web3 import Web3
from web3.middleware import geth_poa_middleware
from ..constants import *
from .utils import *
from .grapQL import *
from .eth_header_manipulation import BlockHeader

def init_eth_with_pk(privatekey):
    """ Initialize blockchain connection """
    web3 = Web3(Web3.HTTPProvider(ETHPROVIDER))
    # ONLY IN RINKEBY!!
    # web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    acc = web3.eth.account.privateKeyToAccount(privatekey)
    web3.eth.default_account = acc.address
    return web3

def get_last_transaction(web3):
    """ return last transaction form blockchain """
    try:
        transaction = web3.eth.get_transaction_by_block(web3.eth.blockNumber, 0)
        tx_dict = dict(transaction)
        tx_json = json.dumps(tx_dict, cls=HexJsonEncoder)
        return tx_json
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
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
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}
