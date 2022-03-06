init: 
	systemctl stop apache2.service
	USER=$(id -u) GROUP=$(id -g)
	docker-compose build
setup:
	docker-compose -f docker-compose-blockchainless.yml up --remove-orphans
start:
	docker-compose -f docker-compose.yml up --remove-orphans
stop:
	docker-compose down
