# for me only :)
stop:
	systemctl stop apache2.service

# build all the stuff
init: 
	USER=$(id -u) GROUP=$(id -g)
	docker-compose build
	python3 ./Server/src/smartContracts/zokrates_compilation.py

# start dev enviroment
dev:
	docker-compose -f docker-compose-blockchainless.yml up --remove-orphans

# start prod enviroment
start:
	docker-compose -f docker-compose.yml up --remove-orphans

# compile and setup zokrates
compile:
	python3 ./Server/main.py compile

# create proof
proof:
	python3 ./Server/main.py proof

# deploy smart contracts
deploy:
	python3 ./Server/main.py deploy

# interact with smart contract
interact:
	python3 ./Server/main.py interact

call:
	python3 ./Server/main.py call