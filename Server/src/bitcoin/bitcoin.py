import requests
import ast
import json
from .jsonRPC import *
from .btc_header_manipulation import BlockHeader

rpc_user = 'blockdaemon'
rpc_password = 'blockdaemon'


def create_proof(start,end):
    """ create proof for block number """
    try:
        firstHeader = getBlockHeaders(start-1,start)
        headers = getBlockHeaders(start, end)
        zkHeaders = ''
        zkTargets = ''
        for header in headers:
            headerObj = BlockHeader(header)
            zkHeaders += (headerObj.zokratesInput) + ' '
            zkTargets += (headerObj.zokratesBlockTarget()) + ' '
        zkInput = zkHeaders + zkTargets + ' ' + str(int(BlockHeader(firstHeader[0]).hash, 16))
        return json.dumps(zkInput)
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}