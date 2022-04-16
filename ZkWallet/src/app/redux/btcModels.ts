import '../utilities/global';
import {reverseHex} from '../utilities/utils';
import '../../../shim';
global.Buffer = global.Buffer || require('buffer').Buffer;
import crypto from 'crypto';

// basic header structure
export class BtcHeader {
  height: string;
  previous_block_hash: string;
  version: string;
  merkle_root: string;
  timestamp: string;
  bits: string;
  nonce: string;
  hash: string;
  // version+previous_block_hash + merkle_root+timestamp+bits+nonce
  constructor(
    version: string,
    previous_block_hash: string,
    merkle_root: string,
    timestamp: string,
    bits: string,
    nonce: string,

    height: string,
    hash: string,
  ) {
    this.version = version;
    this.previous_block_hash = previous_block_hash;
    this.merkle_root = merkle_root;
    this.timestamp = timestamp;
    this.bits = bits;
    this.nonce = nonce;

    this.height = height;
    this.hash = hash;
  }

  // return hash of header object
  getHash(): string {
    const header =
      (reverseHex(this.version) ?? '') +
      ((this.previous_block_hash
        ? reverseHex(this.previous_block_hash)
        : '0'.repeat(64)) ?? '') +
      (reverseHex(this.merkle_root) ?? '') +
      (reverseHex(parseInt(this.timestamp, 10).toString(16)) ?? '') +
      (reverseHex(this.bits) ?? '') +
      (reverseHex(parseInt(this.nonce, 10).toString(16).padStart(8, '0')) ??
        '');
    console.log(header);
    const bufferHash = global.Buffer.from(header, 'hex');
    const headerHash = crypto
      .createHash('sha256')
      .update(crypto.createHash('sha256').update(bufferHash).digest())
      .digest('hex');
    return reverseHex(headerHash) ?? '';
  }

  // check header validity and that it follows previous
  checkValidity(inputPrevHash: string): boolean {
    const head = parseInt(this.bits.substring(0, 2), 16);
    const tail = parseInt(this.bits.substring(2), 16);
    console.log(this.getHash(), this.hash, this.height);
    console.log(this.getHash() === this.hash);
    console.log(this.previous_block_hash === inputPrevHash);
    console.log(tail * Math.pow(2, 8 * (head - 3)) > parseInt(this.hash, 16));
    if (
      // if actual hash is same as recieve
      this.getHash() === this.hash &&
      // if previous hash is actually previous
      this.previous_block_hash === inputPrevHash &&
      // if hash is smaller than difficulty (todo maybe the numbers are to big for js)
      tail * Math.pow(2, 8 * (head - 3)) > parseInt(this.hash, 16)
    ) {
      return true;
    }
    return false;
  }
}

// mapping of validated headers
export class ValidatedHeader {
  [key: number]: string;
}

// mapping of validated transactions
export class ValidatedTransaction {
  [hash: string]: boolean;
}

// payload structure for btc JRPC communication
export class Payload {
  id: string;
  jsonrpc: string;
  method: string;
  params: any[];

  constructor(id: string, params: any[], method: string) {
    this.id = id;
    this.jsonrpc = '2.0';
    this.method = method;
    this.params = params;
  }
}

// basic transaction structure
export class BtcTransaction {
  tx_hash: string;
  transaction_id: number;
  value: number;
  block_height: number;
  validated: boolean = false;
  spending_tx_hash: string;
  spending_block_id: number;
  constructor(
    tx_hash: string,
    value: number,
    block_height: number,
    transaction_id: number,
    spending_tx_hash: string,
    spending_block_id: number,
  ) {
    this.tx_hash = tx_hash;
    this.value = value;
    this.block_height = block_height;
    this.transaction_id = transaction_id;
    this.spending_tx_hash = spending_tx_hash;
    this.spending_block_id = spending_block_id;
  }
}

export class ClosestHashParams {
  blockchainId: number;
  password: string;
  contractAddress: string;
  abi: string;
  target: number;
  constructor(
    blockchainId: number,
    password: string,
    contractAddress: string,
    abi: string,
    target: number,
  ) {
    this.blockchainId = blockchainId;
    this.password = password;
    this.contractAddress = contractAddress;
    this.abi = abi;
    this.target = target;
  }
}
