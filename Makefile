USER=root
REMOTE=$(USER)@$(HOST)
SSH_OPTIONS=-o 'StrictHostKeyChecking no'
SSH = ssh $(SSH_OPTIONS) root@$(HOST)
SERVER_DIR=~/runestone-server
RSYNC_OPTIONS= -e 'ssh -o StrictHostKeyChecking=no'
RSYNC=rsync $(RSYNC_OPTIONS)
TIME = $(shell date +%Y-%m-%d_%Hh%M)
COMPOSE = docker-compose -f docker-compose.yml -f docker-compose-pgadmin.yml

host.env.build:
	@if test -z "$(HOST)"; then echo "variable HOST not defined"; exit 1; fi
	@if test -z "$(POSTGRES_PASSWORD)"; then echo "variable POSTGRES_PASSWORD not defined"; exit 1; fi
	rm -f host.env
	echo "VIRTUAL_HOST=$(HOST)" >> host.env
	echo "LETSENCRYPT_HOST=$(HOST)" >> host.env
	echo "RUNESTONE_HOST=$(HOST)" >> host.env
	echo "POSTGRES_PASSWORD=$(POSTGRES_PASSWORD)" >> host.env

push: host.env.build
	$(RSYNC) -raz . $(REMOTE):$(SERVER_DIR) --progress --exclude=.git --exclude=venv --exclude=ubuntu --exclude=__pycache__


ssh:
	$(SSH)

start:
	$(COMPOSE) start

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