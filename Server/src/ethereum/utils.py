import json
from hexbytes import HexBytes

class HexJsonEncoder(json.JSONEncoder):
    """ Hex encoder class """
    def default(self, obj):
        if isinstance(obj, HexBytes):
            return obj.hex()
        return super().default(obj)