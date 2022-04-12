export class BtcHeader {
  height: string;
  unhexBits: string;
  previous_block_hash: string;
  version: string;
  merkle_root: string;
  timestamp: string;
  bits: string;
  nonce: string;
  hash: string;

  constructor(
    height: string,
    unhexBits: string,
    previous_block_hash: string,
    version: string,
    merkle_root: string,
    timestamp: string,
    bits: string,
    nonce: string,
    hash: string,
  ) {
    this.height = height;
    this.unhexBits = unhexBits;
    this.previous_block_hash = previous_block_hash;
    this.version = version;
    this.merkle_root = merkle_root;
    this.timestamp = timestamp;
    this.bits = bits;
    this.nonce = nonce;
    this.hash = hash;
  }
}

export class Payload {
  id: number;
  jsonrpc: string;
  method: string;
  params: number[];

  constructor(id: number, params: number[], method: string) {
    this.id = id;
    this.jsonrpc = '2.0';
    this.method = method;
    this.params = params;
  }
}

export class BtcTransaction {
  tx_hash: string;
  value: number;
  block_hash: string;
  block_height: number;
  block_index: number;
  validated: boolean = false;

  constructor(
    tx_hash: string,
    value: number,
    block_hash: string,
    block_height: number,
    block_index: number,
  ) {
    this.tx_hash = tx_hash;
    this.value = value;
    this.block_hash = block_hash;
    this.block_height = block_height;
    this.block_index = block_index;
  }
}
