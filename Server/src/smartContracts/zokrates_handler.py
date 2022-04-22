''' Zokrates handling '''

import subprocess, os, logging, json
from src.bitcoin.bitcoin import get_zk_input
from src.utils import *


def init_zokrates(working_directory):
    """ Install and init zokrates if missing """
    os.environ['PATH'] = os.environ['PATH']+':'+os.environ['HOME']+'/.zokrates/bin'
    os.environ['ZOKRATES_HOME'] = os.environ['HOME']+'/.zokrates/stdlib'
    if(subprocess.run('zokrates --version', shell=True, cwd=working_directory, capture_output=True).returncode != 0):
        # get zokrates
        subprocess.run('curl -LSfs get.zokrat.es | sh', shell=True, cwd=working_directory)
        
def compile_validator():
    """ Compile validator """
    working_directory =  os.getcwd() + '/Server/src/smartContracts/zokrates'
    try:
        init_zokrates(working_directory)

        # compile contract
        subprocess.run('zokrates compile -i btcValidation.zok', shell=True, cwd=working_directory)
        logging.info('Compilation finished')
        # setup zksanrks (!warning this produces toxic waste!)
        subprocess.run('zokrates setup', shell=True, cwd=working_directory)
        logging.info('Setup finished')
        # # create smart contract 
        subprocess.run('zokrates export-verifier', shell=True, cwd=working_directory)
        logging.info('Verifier exported')
        # # update contract
        subprocess.run('cp verifier.sol ../contracts/verifier.sol', shell=True, cwd=working_directory)
        logging.info('Updated verifier')

        return True
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return False

def compute_proof(chainId, start, end):
    """ compute proof """
    working_directory =  os.getcwd() + '/Server/src/smartContracts/zokrates'
    try:
        init_zokrates(working_directory)
        logging.info('Zokratres initiated')
        start = str(start)
        end = str(end)
        inputPath = working_directory + '/zokrates'+chainId+start+end
        witenessPath = working_directory + '/witenss' +chainId+start+end
        proofPath = working_directory + '/proof' +chainId+start+end
        with open(inputPath, 'r') as file:
            data = file.read().rstrip()
            subprocess.run('zokrates compute-witness -a ' + data + ' -o ' + witenessPath, shell=True, cwd=working_directory)
            logging.info('Witness created')
            subprocess.run('zokrates generate-proof -j '+ proofPath + ' -w ' + witenessPath , shell=True, cwd=working_directory)
            logging.info('Proof created')
        return True
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return False

def create_proof_for_chain(chainId, start, end):
    """ compute proof """
    start = str(start)
    end = str(end)

    if( int(end) != int(start) + 32):
        logging.info('Gap between start and end needs to be 32')
        return False
    working_directory =  os.getcwd() + '/Server/src/smartContracts/zokrates'

    input = get_zk_input(chainId, start, end).strip('\"')
    # output file is called by its cahin and boundaries
    with open(os.getcwd()+'/Server/src/smartContracts/zokrates/zokrates'+chainId+start+end, 'w') as file:
        file.write(input)
    logging.info('Input generated')
    # write proof to solidity input file
    if(compute_proof(chainId, start, end)):
        # transfer proof to solidity acceptable format
        with open(working_directory + '/proof'+chainId+start+end, 'r') as input:
            with open(working_directory + '/solidity'+chainId+start+end, 'w') as file:
                data = json.load(input)
                result = {'start': int(start), 'end':int(end)}
                result['proof'] = {}
                result['proof']['a'] = castStrListToHex(data["proof"]["a"])
                result['proof']['b'] = castNestedStrListToHex(data["proof"]["b"])
                result['proof']['c'] = castStrListToHex(data["proof"]["c"])
                result['proof']['inputs'] = castStrListToHex(data["inputs"])
                file.write(json.dumps(result))
                return True