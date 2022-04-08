import json, os, logging
from hexbytes import HexBytes

class HexJsonEncoder(json.JSONEncoder):
    """ Hex encoder class """
    def default(self, obj):
        if isinstance(obj, HexBytes):
            return obj.hex()
        return super().default(obj)

def get_contract_info():
    # this leads to container (withnout Server)
    with open(os.getcwd()+'/src/smartContracts/smartContractInfo', 'r') as file:
        data = json.load(file)
        logging.info('Contract is :'+ json.dumps(data))
        return data
