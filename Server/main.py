from src.smartContracts.contract_handler import build_and_deploy, send_batches_to_contract, get_closest_hash
from src.smartContracts.zokrates_handler import create_proof_for_chain, compile_validator
from src.smartContracts.contract_debugger import run_debugger
from src.ethereum.ethereum import init_eth_with_pk
from src.bitcoin.bitcoin import get_zk_input
from src.constants import *
from src.utils import *

import sys
import os
import logging
import json

logging.basicConfig(level=logging.INFO)

if(sys.argv[1] == 'compile'):
    if(compile_validator()):
        logging.info('Compilation succes')

if(sys.argv[1] == 'btcproof'):
    create_proof_for_chain(0, 1, 33)

if(sys.argv[1] == 'proof'):
    chainId = sys.argv[2]
    start = sys.argv[3]
    end = sys.argv[4]
    create_proof_for_chain(chainId, start, end)

if(sys.argv[1] == 'deploy'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        result = build_and_deploy(acc, web3)
        if(result):
            with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'w') as file:
                file.write(json.dumps(result))
                logging.info('Contract at:'+result['contract_address'])

if(sys.argv[1] == 'interact'):
    chainId = sys.argv[2]
    start = sys.argv[3]
    end = sys.argv[4]
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            # sends batches to bitcoin blockchain in contract
            result = send_batches_to_contract(
                chainId, start, end, acc, web3, contract['contract_address'], contract['abi'])
    else:
        logging.info("could not connect to web3")

if(sys.argv[1] == 'btcinteract'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            # sends batches to bitcoin blockchain in contract
            result = send_batches_to_contract(
                0, start, end, acc, web3, contract['contract_address'], contract['abi'])
    else:
        logging.info("could not connect to web3")

if(sys.argv[1] == 'bchinteract'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            # sends batches to bitcoin blockchain in contract
            result = send_batches_to_contract(
                2, start, end, acc, web3, contract['contract_address'], contract['abi'])
    else:
        logging.info("could not connect to web3")

if(sys.argv[1] == 'call'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            result = get_closest_hash(
                acc, web3, contract['contract_address'], contract['abi'], 90)
    else:
        logging.info("could not connect to web3")

if(sys.argv[1] == 'debug'):
    run_debugger()