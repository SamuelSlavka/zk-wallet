''' Bitcoin data handling '''

import requests
import ast
import json
from .jsonRPC import *
from .btc_zok_utils import *
from .btc_header_manipulation import BlockHeader
import json
import subprocess
import os
from web3 import Web3
from web3.middleware import geth_poa_middleware
from hexbytes import HexBytes
from ..constants import *


# contract location
working_directory = os.path.split(os.path.split(os.getcwd())[0])[0] + 'src/smartContracts/'

def create_witness(start,end):
    """ Creates witneses of local execution """
    try:
        zkInput = create_zok_input(start, end)
        # compile contract
        process = subprocess.Popen(['zokrates', 'compute-witness', '--light', '-a', zkInput], cwd=working_directory + 'zokrates/')
        process.wait()
        return json.dumps(zkInput)
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}


    
def compile_validator():
    """ Compile validator """
    try:
        # compile contract
        process = subprocess.Popen(['zokrates', 'compile'], cwd=working_directory + 'zokrates/')
        process.wait()

        # setup zksanrks
        process = subprocess.Popen(['zokrates', 'setup'], cwd=working_directory + 'zokrates/')
        process.wait()

        # setup zksanrks
        process = subprocess.Popen(['zokrates', 'export-verifier'], cwd=working_directory + 'zokrates/')
        process.wait()

        return {'result':'ok'}
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}