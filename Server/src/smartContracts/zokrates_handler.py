''' Zokrates handling '''

import subprocess, os

def init_zokrates(working_directory):
    """ Install and init zokrates if missing """
    if(subprocess.run('zokrates --version', shell=True, cwd=working_directory, capture_output=True).returncode != 0):
        # get zokrates
        subprocess.run('curl -LSfs get.zokrat.es | sh', shell=True, cwd=working_directory)
        
        os.environ['PATH'] = os.environ['PATH']+':'+os.environ['HOME']+'/.zokrates/bin'
        os.environ['ZOKRATES_HOME'] = os.environ['HOME']+'/.zokrates/stdlib'
        subprocess.run('export PATH=$PATH:$HOME/.zokrates/bin', shell=True)
        subprocess.run('export ZOKRATES_HOME=$HOME/.zokrates/stdlib', shell=True)
        
def compile_validator():
    """ Compile validator """
    working_directory =  os.getcwd() + '/Server/src/smartContracts/zokrates'
    try:
        init_zokrates(working_directory)

        # compile contract
        subprocess.run('zokrates compile -i btcValidation.zok', shell=True, cwd=working_directory)

        # setup zksanrks
        subprocess.run('zokrates setup', shell=True, cwd=working_directory)

        # create smart contract (!warning this produces toxic waste!)
        subprocess.run('zokrates export-verifier', shell=True, cwd=working_directory)

        # update contract
        subprocess.run('cp verifier.sol ../contracts/verifier.sol', shell=True, cwd=working_directory)
        return True
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return False

def compute_witness():
    """ compute witness """
    working_directory =  os.getcwd() + '/Server/src/smartContracts/zokrates'
    try:
        init_zokrates(working_directory)
        with open(working_directory+'/zokratesInput', 'r') as file:
            data = file.read().rstrip()
            subprocess.run('zokrates compute-witness -a ' + data, shell=True, cwd=working_directory)
        return True
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return False
