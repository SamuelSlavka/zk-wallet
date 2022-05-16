# Server side

### Setup instructions:
#### Constnts:
If `constants.py` file is missing, rename  `constants.dist.py` to  `constants.py` whre:

`PRIVATE_KEY` = Ethereum privateky from your chosen network with enought eth for contract deployment and interactions.

Replace Tokens and optionaly api urls.

#### Build docker image

    make init

#### Run dockerized flask

    make dev