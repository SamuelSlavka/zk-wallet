export class BtcHeader {
  height: string;
  unhexBits: string;
  previous_block_hash: string = '';
  version: string;
  merkle_root: string;
  timestamp: string;
  bits: string;
  nonce: string;
  hash: string;

  constructor(
    height: string,
    unhexBits: string,
    version: string,
    merkle_root: string,
    timestamp: string,
    bits: string,
    nonce: string,
    hash: string,
  ) {
    this.height = height;
    this.unhexBits = unhexBits;
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
  block_index: number;
  value: number;
  block_height: number;
  validated: boolean = false;
  spending_tx_hash: string;
  spending_block_id: number;
  constructor(
    tx_hash: string,
    value: number,
    block_height: number,
    block_index: number,
    spending_tx_hash: string,
    spending_block_id: number,
  ) {
    this.tx_hash = tx_hash;
    this.value = value;
    this.block_height = block_height;
    this.block_index = block_index;
    this.spending_tx_hash = spending_tx_hash;
    this.spending_block_id = spending_block_id;
  }
}
