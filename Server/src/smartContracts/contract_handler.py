""" Smart contract creation and deployment interaction """
# refs https://github.com/SamuelSlavka/slavkaone

from src.constants import *
from src.ethereum.ethereum import init_eth_with_pk
import json
import subprocess
import os
import sys
import logging

sys.path.insert(0, os.getcwd()+'/Server/src/ethereum')


def compile_contract():
    """ compile all contract files """
    try:
        # install truffle if missing
        if(subprocess.run(('truffle version'), shell=True, capture_output=True).returncode != 0):
            subprocess.run(('npm install -g truffle'), shell=True)

        # contract location
        working_directory = os.getcwd() + '/Server/src/smartContracts/'
        # compile contract
        subprocess.run(('truffle compile'),
                       cwd=working_directory + 'contracts/', shell=True)

        with open(working_directory + 'build/contracts/HeaderList.json', "r") as file:
            contract = json.load(file)
            return contract
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error': err}


def deploy_contract(contractInterface, account, w3):
    """ Instantiate and deploy contract """
    try:
        contract = w3.eth.contract(
            abi=contractInterface['abi'],
            bytecode=contractInterface['bytecode']
        )

        # magic number to enable testnet interaction
        # remove if this ever gets to production!!
        gasMultiplier = 6

        # get gas
        gasPrice = w3.eth.generate_gas_price() * gasMultiplier
        logging.info('GasPrice: ' + str(gasPrice))

        # build contract creation transaction
        construct_txn = contract.constructor().buildTransaction({
            'from': account.address,
            'nonce': w3.eth.getTransactionCount(account.address),
            'gasPrice': gasPrice,
            })

        # sign the transaction
        signed = account.signTransaction(construct_txn)

        # Get transaction hash from deployed contract
        tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
        logging.info('Sent transaction')
        # Get tx receipt to get contract address
        tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
        return tx_receipt['contractAddress']
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error': err}


def build_and_deploy(account, w3):
    """ build and deploy contract """
    if w3.isConnected():
        contract = compile_contract()
        data = {
            'abi': contract['abi'],
            'contract_address': deploy_contract(contract, account, w3)
        }
        return data
    return False


def send_batches_to_contract(blockchainId, start, end, account, w3, contract_address, abi):
    """ Send inputs to contract method """
    if(w3.isConnected()):
        contract = w3.eth.contract(
            address=contract_address,
            abi=abi
        )
        start = str(start)
        end = str(end)
        with open(os.getcwd()+'/Server/src/smartContracts/zokrates/solidity'+ blockchainId + start + end, 'r') as file:
            input = json.load(file)
            logging.info('Proof loaded')
            try:
                gasMultiplier = 3
                # get gas
                gasPrice = w3.eth.generate_gas_price() * gasMultiplier
                logging.info('GasPrice: ' + str(gasPrice))

                nonce = w3.eth.getTransactionCount(account.address)
                logging.info('Building transaction...')
                transaction = contract.functions.submitBatches(
                    int(blockchainId), [input["proof"]], int(input["start"]), int(input["end"])).buildTransaction({'nonce': nonce, 'gasPrice': gasPrice})
                signed_transaction = w3.eth.account.sign_transaction(transaction, PRIVATE_KEY)
                logging.info('Transaction created')
                tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
                logging.info('Transaction sent')
                tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
                logging.info(tx_receipt)
            except Exception as err:
                logging.error(err)
                logging.error('Failed to submit batches')


    return False


def get_closest_hash(account, w3, contract_address, abi, height):
    """ Calls contract method """
    if(w3.isConnected()):
        contract = w3.eth.contract(
            address=contract_address,
            abi=abi
        )
        result = contract.functions.getClosestHash(0, height, 0).call()
        logging.info(result)
    return False
