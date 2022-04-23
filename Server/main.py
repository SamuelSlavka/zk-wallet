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

# generates proofs between start and end
if(sys.argv[1] == 'proof'):
    chainId = sys.argv[2]
    start = sys.argv[3]
    end = sys.argv[4]

    i = int(start)
    while i < int(end):
        logging.info('Proofs for headers:' + 'from: ' + str(i) + ' to: ' +  str(i+32))
        create_proof_for_chain(chainId, i, i+32)
        i += 32

if(sys.argv[1] == 'deploy'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    logging.info('Deploying contract')
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        logging.info('Connected')
        result = build_and_deploy(acc, web3)
        if(result):
            with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'w') as file:
                file.write(json.dumps(result))
                logging.info('Contract at:'+result['contract_address'])
    else:
        logging.info("Could not connect to web3")

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
        logging.info("Could not connect to web3")

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