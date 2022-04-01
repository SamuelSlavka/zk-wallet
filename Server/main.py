from src.smartContracts.contract_handler import build_and_deploy
from src.smartContracts.zokrates_handler import compile_validator, compute_proof
from src.ethereum.ethereum import init_eth_with_pk
from src.bitcoin.bitcoin import get_zk_input
from src.constants import *
import sys, os, logging

logging.basicConfig(level=logging.INFO)

if(sys.argv[1] == 'compile'):
    if(compile_validator()):
        logging.info('Compilation succes')

if(sys.argv[1] == 'proof'):
    input = get_zk_input(1,33).strip('\"')
    with open(os.getcwd()+'/Server/src/smartContracts/zokrates/zokratesInput', 'w') as file:
        file.write(input)
    logging.info('Input generated')
    compute_proof()

if(sys.argv[1] == 'deploy'):
    web3 = init_eth_with_pk(PRIVATE_KEY, ETHPROVIDER)
    acc = web3.eth.account.privateKeyToAccount(PRIVATE_KEY)
    logging.info(acc.address)
    if(web3.isConnected()):
        build_and_deploy(acc, web3)
        logging.info('Contracts deployed')
