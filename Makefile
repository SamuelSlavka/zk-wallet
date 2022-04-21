# for me only :)
stop:
	systemctl stop apache2.service

# build all the stuff
init: 
	USER=$(id -u) GROUP=$(id -g)
	docker-compose build
	python3 ./Server/main.py compile

# start dev enviroment
dev:
	docker-compose -f docker-compose.yml up --remove-orphans

# compile and setup zokrates
compile:
	python3 ./Server/main.py compile

# deploy smart contracts
deploy:
	python3 ./Server/main.py deploy

# create btc proof headers 0 to 32
proof:
	python3 ./Server/main.py proof 0 1 33

# interact with smart contract publishing proof of btc headers 0 to 32
interact:
	python3 ./Server/main.py interact 0 1 33

# call contract get closest header method for btc
call:
	python3 ./Server/main.py call

# run contract debugger print all logs from solidity
debug:
	python3 ./Server/main.py debug