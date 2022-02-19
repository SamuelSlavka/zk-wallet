""" Blockchain interaction """
import json
import subprocess
import os
from web3 import Web3
from web3.middleware import geth_poa_middleware
from hexbytes import HexBytes
from .psql import *
from .constants import *

w3 = Web3(Web3.HTTPProvider(PROVIDER))

# ONLY IN RINKEBY!!
w3.middleware_onion.inject(geth_poa_middleware, layer=0)
#


class HexJsonEncoder(json.JSONEncoder):
    """ Hex encoder class """
    def default(self, obj):
        if isinstance(obj, HexBytes):
            return obj.hex()
        return super().default(obj)


def compile_contract():
    """ compile all contract files """
    try:
        # contract location
        working_directory = os.path.split(os.path.split(os.getcwd())[0])[0] + '/Eth/'
        # compile contract
        process = subprocess.Popen(['truffle', 'compile'], cwd=working_directory + 'contracts/')
        process.wait()

        with open(working_directory + 'build/contracts/MessageList.json', "r") as file:
            contract = json.load(file)
        return contract
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error': err}


def deploy_contract(contract_interface, acct):
    """ Instantiate and deploy contract """
    try:
        contract = w3.eth.contract(
            abi=contract_interface['abi'],
            bytecode=contract_interface['bytecode'])

        # build contract creation transaction
        construct_txn = contract.constructor().buildTransaction({
            'from': acct.address,
            'nonce': w3.eth.getTransactionCount(acct.address),
            'gas': 2000000,
            'gasPrice': w3.toWei('30', 'gwei')})
        # sign the transaction
        signed = acct.signTransaction(construct_txn)

        # Get transaction hash from deployed contract
        tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)

        # Get tx receipt to get contract address
        tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        return tx_receipt['contractAddress']
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error': err}


def request_founds(address, private_key):
    """ Send some eth to client """
    try:
        acc = w3.eth.account.privateKeyToAccount(private_key)
        # build transaction
        signed_txn = w3.eth.account.signTransaction(dict(
            nonce=w3.eth.get_transaction_count(acc.address),
            gasPrice=w3.eth.gas_price,
            gas=100000,
            to=address,
            value=1000000000000000
        ),
            acc.privateKey)
        tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        # Get tx receipt to get contract address
        tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        return tx_receipt
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error': err}


def build_and_deploy(acc):
    """ build and deploy contract """
    if w3.isConnected():
        contract = compile_contract()
        data = {
            'abi': contract['abi'],
            'contract_address': deploy_contract(contract, acc)
        }
        return data
    return False


def get_last_transaction():
    """ return last transaction form blockchain """
    try:
        transaction = w3.eth.get_transaction_by_block(w3.eth.blockNumber, 0)
        tx_dict = dict(transaction)
        tx_json = json.dumps(tx_dict, cls=HexJsonEncoder)
        return tx_json
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}


def init_eth_with_pk(privatekey):
    """ initializes contract and blockchain connection """
    acc = w3.eth.account.privateKeyToAccount(privatekey)
    res = acc.address
    new_contract = False
    w3.eth.default_account = res
    cur = get_contract()
    if cur is None:
        result = build_and_deploy(acc)
        set_contract(result['contract_address'], json.dumps(result['abi']))
        cur = get_contract()
        new_contract = True
    if cur is not None:
        return {'result': True, 'new_contract': new_contract}
    else:
        return {'result': False, 'new_contract': new_contract}
