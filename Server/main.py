from src.smartContracts.contract_handler import build_and_deploy, send_batches_to_contract, get_closest_hash
from src.smartContracts.zokrates_handler import compile_validator, compute_proof
from src.ethereum.ethereum import init_eth_with_pk
from src.bitcoin.bitcoin import get_zk_input
from src.constants import *
from src.utils import *

import sys, os, logging, json

logging.basicConfig(level=logging.INFO)

if(sys.argv[1] == 'compile'):
    if(compile_validator()):
        logging.info('Compilation succes')

if(sys.argv[1] == 'dogeproof'):
    start = 1
    end = 33
    input = get_zk_input(1, start, end).strip('\"')
    with open(os.getcwd()+'/Server/src/smartContracts/zokrates/zokratesInputDoge', 'w') as file:
        file.write(input)
    logging.info('Input generated')
    # write proof to solidity input file
    compute_proof(1)
    # if(compute_proof(1)):
    #     # transfer proof to solidity acceptable format
    #     with open(os.getcwd()+'/Server/src/smartContracts/zokrates/proof.json', 'r') as input:
    #         with open(os.getcwd()+'/Server/src/smartContracts/zokrates/solidityInput', 'w') as file:
    #             data = json.load(input)
    #             result = {'start': start, 'end':end}
    #             result['proof'] = {}
    #             result['proof']['a'] = castStrListToHex(data["proof"]["a"])
    #             result['proof']['b'] = castNestedStrListToHex(data["proof"]["b"])
    #             result['proof']['c'] = castStrListToHex(data["proof"]["c"])
    #             result['proof']['inputs'] = castStrListToHex(data["inputs"])

    #             file.write(json.dumps(result))

if(sys.argv[1] == 'btcproof'):
    start = 1
    end = 33
    input = get_zk_input(0,start,end).strip('\"')
    with open(os.getcwd()+'/Server/src/smartContracts/zokrates/zokratesInputBtc', 'w') as file:
        file.write(input)
    logging.info('Input generated')
    # write proof to solidity input file
    if(compute_proof(0)):
        # transfer proof to solidity acceptable format
        with open(os.getcwd()+'/Server/src/smartContracts/zokrates/proof.json', 'r') as input:
            with open(os.getcwd()+'/Server/src/smartContracts/zokrates/solidityInput', 'w') as file:
                data = json.load(input)
                result = {'start': start, 'end':end}
                result['proof'] = {}
                result['proof']['a'] = castStrListToHex(data["proof"]["a"])
                result['proof']['b'] = castNestedStrListToHex(data["proof"]["b"])
                result['proof']['c'] = castStrListToHex(data["proof"]["c"])
                result['proof']['inputs'] = castStrListToHex(data["inputs"])

                file.write(json.dumps(result))

if(sys.argv[1] == 'deploy'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        result = build_and_deploy(acc, web3)
        if(result):
            with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'w') as file:
                file.write(json.dumps(result))
                logging.info('Contract at:'+result['contract_address'])

if(sys.argv[1] == 'btcinteract'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            # sends batches to bitcoin blockchain in contract
            result = send_batches_to_contract(0, acc, web3, contract['contract_address'], contract['abi'])
    else:
        logging.info("could not connect to web3")

if(sys.argv[1] == 'dogeinteract'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            # sends batches to bitcoin blockchain in contract
            result = send_batches_to_contract(1, acc, web3, contract['contract_address'], contract['abi'])
    else:
        logging.info("could not connect to web3")

if(sys.argv[1] == 'call'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            result = get_closest_hash(acc, web3, contract['contract_address'], contract['abi'], 90)
    else:
        logging.info("could not connect to web3")
