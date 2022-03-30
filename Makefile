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

# create witness
witness:
	python3 ./Server/main.py witness

# deploy smart contracts
deploy:
	python3 ./Server/main.py deploy