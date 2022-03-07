""" Smart contract creation and deployment interaction """
import json
import subprocess
import os
from web3 import Web3
from web3.middleware import geth_poa_middleware
from hexbytes import HexBytes
from ..constants import *

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


def deploy_contract(contractInterface, account, w3):
    """ Instantiate and deploy contract """
    try:
        contract = w3.eth.contract(
            abi=contractInterface['abi'],
            bytecode=contractInterface['bytecode'])

        # build contract creation transaction
        construct_txn = contract.constructor().buildTransaction({
            'from': account.address,
            'nonce': w3.eth.getTransactionCount(account.address),
            'gas': 2000000,
            'gasPrice': w3.toWei('30', 'gwei')})
        # sign the transaction
        signed = account.signTransaction(construct_txn)

        # Get transaction hash from deployed contract
        tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)

        # Get tx receipt to get contract address
        tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        return tx_receipt['contractAddress']
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error': err}

def build_and_deploy(account, w3):
    """ build and deploy contract """
    if w3.isConnected():
        contract = compile_contract()
        data = {
            'abi': contract['abi'],
            'contract_address': deploy_contract(contract, account)
        }
        return data
    return False
