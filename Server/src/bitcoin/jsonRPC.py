''' JSON rpc connection mangment '''

import requests
import json
from ..constants import *
import argparse
import sys

def getPayload(id, params, function):
    return {
        "id": str(id),
        "jsonrpc": "2.0",
        "method": function,
        "params": [params],
    }

def getBlockHeaders(chainId, begining, end):
    """ create proof for block number """

    token = DOGETOKEN if chainId else BTCTOKEN
    provider = DOGEPROVIDER if chainId else BTCPROVIDER

    headers = {
        'Content-Type': 'application/json',
        "x-api-key": token,
        "X-Auth-Token": token,
    }

    # get block hashes
    payload = json.dumps([getPayload(block, block, 'getblockhash') for block in range(begining, end)])
    response = requests.post(provider, headers=headers, data=payload, allow_redirects=False, timeout=30)
    # get block headers
    payload = json.dumps([getPayload(block['id'], block['result'], 'getblock') for block in response.json()])
    response = requests.post(provider, headers=headers, data=payload, allow_redirects=False, timeout=30).json()
    return response