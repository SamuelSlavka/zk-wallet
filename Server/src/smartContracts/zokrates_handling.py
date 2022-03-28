''' Bitcoin data handling '''

from ..bitcoin.bitcoin import *
import subprocess
import os
import subprocess
from ..constants import *

def create_witness(start,end):
    """ Creates witneses of local execution """
    working_directory =  os.path.split(os.path.split(os.getcwd())[0])[0] + 'src/src/smartContracts/zokrates'
    try:
        zkInput = create_zok_input(start, end)
        # compile contract
        process = subprocess.Popen('zokrates compute-witness --light -a '+ zkInput, cwd=working_directory)
        process.wait()
        return {'result':'ok'}
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}


    
def compile_validator():
    """ Compile validator """
    working_directory =  os.path.split(os.path.split(os.getcwd())[0])[0] + 'src/src/smartContracts/zokrates'
    try:
        # compile contract
        process = subprocess.Popen('zokrates compile -i btcValidation.zok', shell=True, cwd=working_directory)
        process.wait()

        # setup zksanrks
        process = subprocess.Popen('zokrates setup', shell=True, cwd=working_directory)
        process.wait()

        # create smart contract
        process = subprocess.Popen('zokrates export-verifier', shell=True, cwd=working_directory)
        process.wait()

        # move contract to contracts
        process = subprocess.Popen('cp verifier.sol ../contracts/verifier.sol', shell=True, cwd=working_directory)
        process.wait()

        return {'result':'ok'}
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}