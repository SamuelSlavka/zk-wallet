import requests
import json
from .jsonRPC import *

rpc_user = 'blockdaemon'
rpc_password = 'blockdaemon'

def create_proof(blockNumber):
    """ create proof for block number """
    try:
        headers = getBlockHeaders(0,blockNumber)
        return headers
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}