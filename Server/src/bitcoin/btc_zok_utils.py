''' Zokrates data handling '''

from .jsonRPC import *
from .btc_header_manipulation import BlockHeader
import logging

def create_zok_input(chainId, start, end):
    """ Get zok input for blocks """
    try:
        firstHeader = getBlockHeaders(chainId, start-1,start)
        headers = getBlockHeaders(chainId, start, end)
        zkHeaders = ''
        zkHashaes = ''
        for header in headers:
            headerObj = BlockHeader(header)
            # headers formated for zk as set of fields
            zkHeaders += (headerObj.zokratesInput) + ' '
            # block hashes as fields
            zkHashaes += str(int(headerObj.hash, 16)) + ' '
        zkInput = zkHeaders + zkHashaes + str(int(BlockHeader(firstHeader[0]).hash, 16)) 
        return zkInput
    except Exception as err:
        logging.error("Error '{0}' occurred.".format(err))
        return {'error':'Error while fetching transaction'}