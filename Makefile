stopApache:
	systemctl stop apache2.service
init: 
	USER=$(id -u) GROUP=$(id -g)
	docker-compose build
dev:
	docker-compose -f docker-compose-blockchainless.yml up --remove-orphans
start:
	docker-compose -f docker-compose.yml up --remove-orphans
stop:
	docker-compose down
