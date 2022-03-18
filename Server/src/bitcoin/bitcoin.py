import requests
import ast
import json
from .jsonRPC import *
from .btc_header_manipulation import BlockHeader

rpc_user = 'blockdaemon'
rpc_password = 'blockdaemon'


def create_proof(blockNumber):
    """ create proof for block number """
    try:
        headers = getBlockHeaders(0,blockNumber)
        hashes = []
        for header in headers:
            headerObj = BlockHeader(header)
            print(headerObj.header.hex())
            print(headerObj.zokratesInput)
            print(headerObj.getBlockTarget())
            hashes.append(headerObj.hash)
        return json.dumps(hashes)
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}