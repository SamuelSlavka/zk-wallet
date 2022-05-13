# build all the stuff
init: 
	USER=$(id -u) GROUP=$(id -g)
	docker-compose build

# start dev enviroment
dev:
	docker-compose -f docker-compose.yml up --remove-orphans

# compile and setup zokrates
compile:
	python3 ./Server/main.py compile

# deploy smart contracts
deploy:
	python3 ./Server/main.py deploy

# create btc proofs headers 0 to 33
proof:
	python3 ./Server/main.py proof 0 1 33

# interact with smart contract publishing proof of btc headers 0 to 32
interact:
	python3 ./Server/main.py interact 0 1 33

# interact with 3 batches
interact10:
	python3 ./Server/main.py interact 0 33 97

# call contract get closest header method for btc
call:
	python3 ./Server/main.py call

# run contract debugger print all logs from solidity
debug:
	python3 ./Server/main.py debug