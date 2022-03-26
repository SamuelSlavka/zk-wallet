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
        hashes = []
        zokratesHeaders = []
        expectedTargets = []
        for header in headers:
            headerObj = BlockHeader(header)
            zokratesHeaders.append(headerObj.zokratesInput)
            expectedTargets.append(headerObj.zokratesBlockTarget())
            hashes.append(headerObj.hash)
        return json.dumps({'headers': zokratesHeaders, 'targets': expectedTargets, 'firstHash': BlockHeader(firstHeader[0]).hash})
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}