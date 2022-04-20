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

# create btc proof
btcproof:
	python3 ./Server/main.py btcproof

# create proof
proof:
	python3 ./Server/main.py proof 0 1 33

# interact with smart contract
btcinteract:
	python3 ./Server/main.py btcinteract

# interact with smart contract
interact:
	python3 ./Server/main.py interact 0 1 33

# deploy smart contracts
deploy:
	python3 ./Server/main.py deploy

# call contract method default btc
call:
	python3 ./Server/main.py call

# run contract debugger
debug:
	python3 ./Server/main.py debug