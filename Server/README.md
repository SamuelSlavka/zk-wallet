# Server side

### Setup instructions:
#### rename  `constants.dist.py` to  `constants.py`

      `PRIVATE_KEY` = Ethereum privateky from your chosen network with enought eth for contract deployment and interactions.

      Replace Tokens and optionaly api urls.

#### for ganache add the following at the end
      # ganache
      PRIVATE_KEY = PK you get from ganache directly
      ETHPROVIDER = 'HTTP://127.0.0.1:7545'