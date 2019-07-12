COMPOSE = docker-compose -f docker-compose.yml -f docker-compose-pgadmin.yml

stop:
	$(COMPOSE) stop

rm: stop
	$(COMPOSE) rm -f

up:
	$(COMPOSE) up -d
logs:
	$(COMPOSE) logs runestone

pgadmin-restart:
	$(COMPOSE) restart pgadmin

full-restart: stop rm up

psql:
	$(COMPOSE) exec db psql -U runestone -W

config:
	$(COMPOSE) config