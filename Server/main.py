from src.smartContracts.contract_handler import build_and_deploy, interact_with_contract
from src.smartContracts.zokrates_handler import compile_validator, compute_proof
from src.ethereum.ethereum import init_eth_with_pk
from src.bitcoin.bitcoin import get_zk_input
from src.constants import *
import sys, os, logging, json

logging.basicConfig(level=logging.INFO)

if(sys.argv[1] == 'compile'):
    if(compile_validator()):
        logging.info('Compilation succes')

if(sys.argv[1] == 'proof'):
    start = 1
    end = 33
    # input = get_zk_input(start,end).strip('\"')
    # print(input)
    # with open(os.getcwd()+'/Server/src/smartContracts/zokrates/zokratesInput', 'w') as file:
    #     file.write(input)
    # logging.info('Input generated')
    # # write proof to solidity input file
    # if(compute_proof()):
    with open(os.getcwd()+'/Server/src/smartContracts/zokrates/proof.json', 'r') as input:
        with open(os.getcwd()+'/Server/src/smartContracts/zokrates/solidityInput', 'w') as file:
            data = json.load(input)
            file.write(json.dumps([[*data['proof'].values(),data['inputs']]])+','+str(start)+','+str(end))

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
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    if(web3.isConnected()):
        with open(os.getcwd()+'/Server/src/smartContracts/smartContractInfo', 'r') as file:
            contract = json.load(file)
            result = interact_with_contract(acc, web3, contract['contract_address'], contract['abi'])
