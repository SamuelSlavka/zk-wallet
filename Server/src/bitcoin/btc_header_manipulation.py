""" BTC header manipulation """

from hashlib import sha256
import struct
import binascii
from bitstring import BitArray
import json

def hexify(value):
    return binascii.hexlify(binascii.unhexlify(value)[::-1])

def getTarget(bits):
    a = int(bits[:2], 16)
    b = int(bits[2:], 16)
    return(b * 2**(8*(a - 3)))


class BlockHeader:
    def __init__(self, input):
        input = input['result']
        self.height = input['height']
        self.unhexBits = input['bits']

        # handling genesis block
        self.previous_block_hash = hexify(str("{:064d}".format(0)))
        if ('previousblockhash' in input):
            self.previous_block_hash = hexify(input['previousblockhash'])
        
        self.version = hexify(input['versionHex'])
        self.merkle_root = hexify(input['merkleroot'])
        self.timestamp = hexify(format(input['time'], 'x'))
        self.bits = hexify(input['bits'])
        # padding nonce to 8 chars
        self.nonce = hexify(format(input['nonce'], 'x').zfill(8))

    def __str__(self) -> str:
        return f'BlockHeader #{self.height} {self.hash}'

    _hash = None
    _header = None
    _zokratesHeader = None
    _zokratesTarget = None

    def zokratesBlockTarget(self):
        """ Returns expected target in zokratess expected form """
        chunk_size = 16
        target = getTarget(self.unhexBits)
        # pad target to 64 and remove 0x
        newTarget = f"{target:#0{66}x}"[2:]
        # split traget to u64 values
        splitHeader = [int((newTarget)[i:i+chunk_size], 16)
                        for i in range(0, len(newTarget), chunk_size)]
        splitHeaderStr = ' '.join(str(x) for x in splitHeader)
        return splitHeaderStr

    @property
    def header(self):
        """ Returns bit representation of header """
        if self._header is None:
            header = self.version+self.previous_block_hash + \
                self.merkle_root+self.timestamp+self.bits+self.nonce
            self._header = binascii.unhexlify(header)
        return self._header

    @property
    def zokratesInput(self):
        """ Returns zokrates expected representation of header """
        if self._zokratesHeader is None:
            # split to 5 parts with 128 bits to field values
            chunk_size = 32
            splitHeader = [int(self.header.hex()[i:i+chunk_size], 16)
                           for i in range(0, len(self.header.hex()), chunk_size)]
            self._zokratesHeader = ' '.join(str(x) for x in splitHeader)
        return self._zokratesHeader

    @property
    def zokratesTarget(self):
        """ Returns prev header target in zokrates program format """
        if self._zokratesTarget is None:
            prevBlock = self.previous_block_hash.decode()
            splitPrevBlock = [prevBlock[i:i+8]
                              for i in range(0, len(prevBlock), 8)]
            self._zokratesTarget = ['0x' + s for s in splitPrevBlock]

        return self._zokratesTarget

    @property
    def hash(self):
        """ Calculates hash for header object """
        if self._hash is None:
            binHeader = self.header
            hash = sha256(sha256(binHeader).digest()).digest()
            hash = binascii.hexlify(hash)
            self._hash = binascii.hexlify(
                binascii.unhexlify(hash)[::-1]).decode('ascii')
        return self._hash
