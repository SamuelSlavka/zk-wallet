''' Zokrates data handling '''

from .jsonRPC import *
from .btc_header_manipulation import BlockHeader

def create_zok_input(start,end):
    """ Get zok input for blocks """
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

        return zkInput
    except Exception as err:
        print("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}