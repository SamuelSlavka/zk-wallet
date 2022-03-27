''' JSON rpc connection mangment '''

import requests
import json
from ..constants import *
import argparse
import sys


headers = {
    'Content-Type': 'application/json',
    "X-Auth-Token": "ZlwlTalKafZepsGxV1-mes2kvwUq5WNNxooVxcNpTAA"
}

def getPayload(id, params, function):
    return {
        "id": id,
        "jsonrpc": "2.0",
        "method": function,
        "params": [params],
    }

def getBlockHeaders(begining, end):
    """ create proof for block number """
    # get block hashes
    payload = json.dumps([getPayload(block,block, 'getblockhash') for block in range(begining, end)])
    response = requests.post(BTCPROVIDER, headers=headers, data=payload, allow_redirects=False, timeout=30)
    
    # get block headers
    payload = json.dumps([getPayload(block['id'], block['result'], 'getblock') for block in response.json()])
    response = requests.post(BTCPROVIDER, headers=headers, data=payload, allow_redirects=False, timeout=30).json()
    return response