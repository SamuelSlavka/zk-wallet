""" graphQl interface """

import requests
import json

from numpy import number
from ..constants import *
from types import SimpleNamespace

def getBlockHeaders(begining, end):
    query = """
    query getHeader {
    blocks(from: "%s", to: "%s") {
        parent { hash }
        ommerHash
        miner { address }
        stateRoot
        transactionsRoot
        receiptsRoot
        logsBloom
        difficulty
        number
        gasLimit
        gasUsed
        timestamp
        extraData
        mixHash
        nonce
    }
    }
    """ % (begining, end)
    url = GRAPH
    response = requests.post(url, json={'query': query}, headers={'X-Auth-Token': TOKEN})
    return json.loads(response.text)['data']