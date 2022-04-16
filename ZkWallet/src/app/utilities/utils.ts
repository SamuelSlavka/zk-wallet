// changes endianness of hex string
export const reverseHex = (hexNum: string) =>
  hexNum?.match(/../g)?.reverse().join('');

// parse raw proof to hashes
export const parseProof = (
  proof: string,
): {hashCount: number; hashes: string[]; flags: number[]} => {
  // const header = reverseHex(proof.substring(160));
  // const txCount = parseInt(reverseHex(proof.substring(160, 168)) ?? '', 16);
  const hashCount = parseInt(reverseHex(proof.substring(168, 170)) ?? '', 16);
  const hashes = [];
  for (let i = 0; i < hashCount; i++) {
    hashes.push(proof.substring(170 + i * 64, 234 + i * 64));
  }
  const pos = 170 + hashCount * 64;
  const flagBits = parseInt(
    reverseHex(proof.substring(pos, pos + 2)) ?? '',
    16,
  );
  const flags = [];
  for (let i = 0; i < flagBits; i++) {
    flags.push(
      parseInt(
        reverseHex(proof.substring(pos + 2 + i * 2, pos + 4 + i * 2)) ?? '',
        16,
      ),
    );
  }
  return {hashCount, hashes, flags};
};
