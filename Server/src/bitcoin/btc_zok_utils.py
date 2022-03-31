''' Zokrates data handling '''

from .jsonRPC import *
from .btc_header_manipulation import BlockHeader
import logging

def create_zok_input(start,end):
    """ Get zok input for blocks """
    try:
        firstHeader = getBlockHeaders(start-1,start)
        headers = getBlockHeaders(start, end)
        zkHeaders = ''
        zkTargets = ''
        zkHashaes = ''
        for header in headers:
            headerObj = BlockHeader(header)
            # headers formated for zk as set of fields
            zkHeaders += (headerObj.zokratesInput) + ' '
            # targets formated for zk as set of u64
            zkTargets += (headerObj.zokratesBlockTarget()) + ' '
            # block hashes as fields
            zkHashaes += str(int(headerObj.hash, 16)) + ' '
        zkInput = zkHeaders + zkTargets + zkHashaes + str(int(BlockHeader(firstHeader[0]).hash, 16)) 
        return zkInput
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}