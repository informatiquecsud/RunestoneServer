COMPOSE = docker-compose -f docker-compose.yml -f docker-compose-pgadmin.yml

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

full-restart: stop rm up logsf

psql:
	$(COMPOSE) exec db psql -U runestone -W

config:
	$(COMPOSE) config

pgadmin-bash:
	$(COMPOSE) exec pgadmin sh