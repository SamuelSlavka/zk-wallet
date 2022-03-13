""" BTC header manipulation """

from hashlib import sha256
import struct
import binascii
from bitstring import BitArray


def hexify(value):
    return binascii.hexlify( binascii.unhexlify(value)[::-1])

class BlockHeader:
    def __init__(self, input):
        input = input['result']
        self.height = input['height']

        # handling genesis block
        self.previous_block_hash = hexify(str("{:064d}".format(0)))
        if ('previousblockhash' in input):
            self.previous_block_hash = hexify(input['previousblockhash'])

        self.version = hexify(input['versionHex'])
        self.merkle_root = hexify(input['merkleroot'])
        self.timestamp = hexify(format(input['time'], 'x'))
        self.bits = hexify(input['bits'])
        self.nonce = hexify(format(input['nonce'], 'x'))

    def __str__(self) -> str:
        return f'BlockHeader #{self.height} {self.hash}'

    _hash = None
    _header = None
    _binHeader = None

    @property
    def header(self):
        """ Returns bit representation of header """
        if self._header is None:
            header = self.version+self.previous_block_hash + \
                self.merkle_root+self.timestamp+self.bits+self.nonce
            self._header = binascii.unhexlify(header)
        return self._header
 
    @property
    def binaryHeader(self):
        """ Returns binary representation of header """
        if self._binHeader is None:
            header = self.version+self.previous_block_hash + \
                self.merkle_root+self.timestamp+self.bits+self.nonce
            binHeader = "".join(f"{byte:08b}" for byte in header)
            print(len(header))
            # split to 5 parts with 128 bits
            chunk_size = 256
            splitHeader = [ binHeader[i:i+chunk_size] for i in range(0, len(binHeader), chunk_size) ]
            # convert chunks to dec
            result = []
            for chunk in splitHeader:
                result.append(int(chunk, 2))

            self._binHeader = result
        return self._binHeader

    @property
    def hash(self):
        """ Calculates hash for header object """
        if self._hash is None:
            print(self.binaryHeader)
            binHeader = self.header
            hash = sha256(sha256(binHeader).digest()).digest()
            hash = binascii.hexlify(hash)
            self._hash = binascii.hexlify(binascii.unhexlify(hash)[::-1]).decode('ascii')
        return self._hash