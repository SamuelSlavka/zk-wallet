""" Header chain manipulation """
# https://github.com/ethereum/py-evm/blob/master/eth/rlp/headers.py

import rlp
from eth_hash.auto import keccak
from eth_typing import Hash32
from eth_utils import encode_hex
from typing import cast

from rlp.sedes import (
    big_endian_int,
    Binary,
    binary,
)

from eth_typing import (
    Address,
    BlockNumber,
    Hash32,
)

from eth_hash.auto import keccak

from eth_utils import (
    encode_hex,
    decode_hex,
)

from rlp.sedes import (
    BigEndianInt,
    Binary,
)

address = Binary.fixed_length(20, allow_empty=True)
hash32 = Binary.fixed_length(32)
uint32 = BigEndianInt(32)
uint256 = BigEndianInt(256)
trie_root = Binary.fixed_length(32, allow_empty=True)
chain_gaps = rlp.sedes.List((
    rlp.sedes.CountableList(rlp.sedes.List((uint32, uint32))),
    uint32,
))


class BlockHeader(rlp.Serializable):
    fields = [
        ('parent_hash', hash32),
        ('uncles_hash', hash32),
        ('coinbase', address),
        ('state_root', trie_root),
        ('transaction_root', trie_root),
        ('receipt_root', trie_root),
        ('bloom', uint256),
        ('difficulty', big_endian_int),
        ('block_number', big_endian_int),
        ('gas_limit', big_endian_int),
        ('gas_used', big_endian_int),
        ('timestamp', big_endian_int),
        ('extra_data', binary),
        ('mix_hash', binary),
        ('nonce', Binary(8, allow_empty=True))
    ]

    def __init__(self, input) -> None:
        super().__init__(
            parent_hash=decode_hex(input['parent']['hash']),
            uncles_hash=decode_hex(input['ommerHash']),
            coinbase=decode_hex(input['miner']['address']),
            state_root=decode_hex(input['stateRoot']),
            transaction_root=decode_hex(input['transactionsRoot']),
            receipt_root=decode_hex(input['receiptsRoot']),
            bloom=int(input['logsBloom'], 16),
            difficulty=int(input['difficulty'],16),
            block_number=int(input['number']),
            gas_limit=int(input['gasLimit']),
            gas_used=int(input['gasUsed']),
            timestamp=int(input['timestamp'],16),
            extra_data=decode_hex(input['extraData']),
            mix_hash=decode_hex(input['mixHash']),
            nonce=decode_hex(input['nonce']),
        )

    def __str__(self) -> str:
        return f'BlockHeader #{self.block_number} {encode_hex(self.hash)}'

    _hash = None

    @property
    def hash(self) -> Hash32:
        if self._hash is None:
            self._hash = keccak(rlp.encode(self))
        return cast(Hash32, self._hash)
