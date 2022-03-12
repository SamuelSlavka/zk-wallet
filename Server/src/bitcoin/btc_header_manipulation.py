""" BTC header chain manipulation """

from hashlib import sha256
import struct
import binascii


def hexify(value):
    return binascii.hexlify( binascii.unhexlify(value)[::-1])


class BlockHeader:
    def __init__(self, input):
        input = input['result']
        self.height = input['height']

        self.version = hexify(input['versionHex'])
        self.previous_block_hash = hexify(input['previousblockhash'])
        self.merkle_root = hexify(input['merkleroot'])
        self.timestamp = hexify(format(input['time'], 'x'))
        self.bits = hexify(input['bits'])
        self.nonce = hexify(format(input['nonce'], 'x'))

    def __str__(self) -> str:
        return f'BlockHeader #{self.height} {self.hash}'

    _hash = None

    @property
    def hash(self):
        if self._hash is None:
            header = self.version+self.previous_block_hash + \
                self.merkle_root+self.timestamp+self.bits+self.nonce

            header = binascii.unhexlify(header)
            hash = sha256(sha256(header).digest()).digest()
            hash = binascii.hexlify(hash)

            self._hash = binascii.hexlify(binascii.unhexlify(hash)[::-1]).decode('ascii')
        return self._hash
