''' Bitcoin data handling '''

import json, logging
from .jsonRPC import *
from .btc_zok_utils import *
from ..constants import *

def get_zk_input(start, end):
    try:
        zkInput = create_zok_input(start, end)
        return json.dumps(zkInput)
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}
