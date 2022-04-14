''' Zokrates handling '''

import subprocess, os, logging

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

def compute_proof(chainId):
    """ compute proof """
    working_directory =  os.getcwd() + '/Server/src/smartContracts/zokrates'
    try:
        init_zokrates(working_directory)
        logging.info('Zokratres initiated')
        input = '/zokratesInputBch' if chainId == 2 else '/zokratesInputBtc'
        with open(working_directory + input, 'r') as file:
            data = file.read().rstrip()
            subprocess.run('zokrates compute-witness -a ' + data, shell=True, cwd=working_directory)
            logging.info('Witness created')
            subprocess.run('zokrates generate-proof', shell=True, cwd=working_directory)
            logging.info('Proof created')
        return True
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return False
