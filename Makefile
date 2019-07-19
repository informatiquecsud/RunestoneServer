COMPOSE = docker-compose -f docker-compose.yml -f docker-compose-pgadmin.yml

start:
	$(COMPOSE) start

ngrok:
	./ngrok.exe http 80

stop:
	$(COMPOSE) stop

rm: stop
	$(COMPOSE) rm -f
	rm -rf dabases

up:
	$(COMPOSE) up -d
top:
	$(COMPOSE) top
dblogs:
	$(COMPOSE) logs db

logs:
	$(COMPOSE) logs runestone
logsf:
	$(COMPOSE) logs -f runestone

pgadmin-restart:
	$(COMPOSE) restart pgadmin

runestone-rm:
	$(COMPOSE) stop runestone
	$(COMPOSE) rm -f runestone

runestone-image: runestone-rm
	docker build -t runestone/server .
runestone-restart:
	$(COMPOSE) stop runestone
	$(COMPOSE) rm -f runestone
	$(COMPOSE) up -d runestone
runestone-exec-bash:
	$(COMPOSE) exec runestone bash


full-restart: stop rm up logsf

psql:
	$(COMPOSE) exec db psql -U runestone -W

config:
	$(COMPOSE) config

pgadmin-bash:
	$(COMPOSE) exec pgadmin sh