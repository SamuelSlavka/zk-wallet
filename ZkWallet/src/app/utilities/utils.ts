// changes endianness of hex string
export const reverseHex = (hexNum: string) =>
  hexNum?.match(/../g)?.reverse().join('');
