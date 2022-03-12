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
        headers = getBlockHeaders(125552,blockNumber)
        for header in headers:
            print(BlockHeader(header).hash)
        return BlockHeader(headers[0]).hash
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}