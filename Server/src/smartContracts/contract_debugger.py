import json, logging, os, time
from web3 import Web3
from src.constants import *

def run_debugger():
    w3 = Web3(Web3.HTTPProvider(ETHPROVIDER))
    logging.info('Running debugger')
    with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
        contract = json.load(file)

        contractAddress = Web3.toChecksumAddress(contract['contract_address'])
        contract = w3.eth.contract(address=contractAddress, abi=contract['abi'])
        loggingEvent = contract.events.Logger()

        def handle_event(event):
            logging.info('Got event')
            receipt = w3.eth.waitForTransactionReceipt(event['transactionHash'])
            result = loggingEvent.processReceipt(receipt)
            print(result[0]['args'])

        def log_loop(event_filter, poll_interval):
            while True:
                for event in event_filter.get_new_entries():
                    handle_event(event)
                    time.sleep(poll_interval)

        block_filter = w3.eth.filter({'fromBlock':'latest', 'address':contractAddress})
        log_loop(block_filter, 2)