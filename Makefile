setup:
	USER=$(id -u) GROUP=$(id -g) 
	docker-compose build
	docker-compose up --remove-orphans
start:
	docker-compose up -d
stop:
	docker-compose down