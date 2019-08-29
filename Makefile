USER=root
HOST=$(RUNESTONE_HOST)
REMOTE=$(USER)@$(HOST)
SSH_OPTIONS=-o 'StrictHostKeyChecking no'
SSH = ssh $(SSH_OPTIONS) root@$(HOST)
SERVER_DIR=~/runestone-server
SERVER_COMPONENTS_DIR=/RunestoneComponents
COMPONENTS_DIR=../RunestoneComponents
RSYNC_OPTIONS= -e 'ssh -o StrictHostKeyChecking=no' --progress --exclude=.git --exclude=venv --exclude=ubuntu --exclude=__pycache__ --delete
RSYNC=rsync $(RSYNC_OPTIONS)
TIME = $(shell date +%Y-%m-%d_%Hh%M)

RUNSTONE_CONTAINER_ID=$(shell docker-compose ps -q runestone)

COMPOSE_PGADMIN = -f docker-compose-pgadmin.yml

WEB2PY_BOOKS = /srv/web2py/applications/runestone/books

# need to run the server-init rule for this to work
ifdef RUNESTONE_REMOTE
	COMPOSE_OPTIONS = -f docker-compose-production.yml
else
	COMPOSE_OPTIONS = -f docker-compose-local.yml
endif

COMPOSE = docker-compose -f docker-compose.yml $(COMPOSE_PGADMIN) $(COMPOSE_OPTIONS)

# shows hot to load the env vars defined in .env
howto-load-dotenv:
	@echo 'set -a; source .env; set +a'

echo-compose-options:
	@echo 'Compose options is: ' $(COMPOSE_OPTIONS)

.env.build:
	@if test -z "$(HOST)"; then echo "variable HOST not defined"; exit 1; fi
	@if test -z "$(POSTGRES_PASSWORD)"; then echo "variable POSTGRES_PASSWORD not defined"; exit 1; fi
	@if test -z "$(WEB2PY_PASSWORD)"; then echo "variable WEB2PY_PASSWORD not defined"; exit 1; fi
	@if test -z "$(PGADMIN_PASSWORD)"; then echo "variable PGADMIN_PASSWORD not defined"; exit 1; fi
	rm -f .env
	echo "RUNESTONE_HOST=$(HOST)" >> .env
	echo "POSTGRES_PASSWORD=$(POSTGRES_PASSWORD)" >> .env
	echo "WEB2PY_PASSWORD=$(WEB2PY_PASSWORD)" >> .env
	echo "PGADMIN_PASSWORD=$(PGADMIN_PASSWORD)" >> .env

push: .env.build
	$(RSYNC) -raz . $(REMOTE):$(SERVER_DIR) --progress --exclude=.git --exclude=venv --exclude=ubuntu --exclude=build --exclude=published --exclude=__pycache__ --delete
	$(SSH) 'echo "RUNESTONE_REMOTE=true" >> $(SERVER_DIR)/.env'


ssh:
	$(SSH)

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

rm: stop
	$(COMPOSE) rm -f
	rm -rf databases

ps:
	$(COMPOSE) ps


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


db-rm:
	$(COMPOSE) stop db
	$(COMPOSE) rm -f db
db-up:
	$(COMPOSE) up -d db
db-restart: db-rm db-up

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
runestone-ps:
	$(COMPOSE) ps
runestone-update-components:
	# $(COMPOSE) exec runestone pip install --upgrade
	# git+git://github.com/informatiquecsud/RunestoneComponents.git
	@echo copying runestone components to container $(RUNSTONE_CONTAINER_ID)
	$(COMPOSE) exec runestone rm -rf $(SERVER_COMPONENTS_DIR)
	docker cp $(COMPONENTS_DIR) $(RUNSTONE_CONTAINER_ID):$(SERVER_COMPONENTS_DIR)
	$(COMPOSE) exec runestone pip install --upgrade -e $(SERVER_COMPONENTS_DIR)
	
	
runestone-rebuild-oxocard101:
	$(COMPOSE) exec runestone bash -c "cd $(WEB2PY_BOOKS)/oxocard101 && runestone build deploy"



full-restart: stop rm up logsf

psql:
	$(COMPOSE) exec db psql -U runestone -W

config:
	$(COMPOSE) config

pgadmin-bash:
	$(COMPOSE) exec pgadmin sh
pgadmin-restart:
	$(COMPOSE) restart pgadmin
pgadmin-rm:
	$(COMPOSE) rm pgadmin
pgadmin-up:
	$(COMPOSE) up pgadmin


server-init:
	$(SSH) 'echo "export RUNESTONE_REMOTE=true" >> ~/.bashrc'


server-proxy-start:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose build && docker-compose up -d'
server-proxy-down:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose down'
server-proxy-logs:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose logs'
server-proxy-logsf:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose logs -f'
server-proxy-bash:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose exec nginx-proxy bash'
server-proxy-ps:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose ps'
server-proxy-conf:
	$(SSH) 'cd $(SERVER_DIR)/nginx-letsencrypt && docker-compose exec nginx-proxy cat /etc/nginx/conf.d/default.conf'

	

server-ll:
	$(SSH) 'cd $(SERVER_DIR) && ls -al'
server-runestone-ps:
	$(SSH) 'cd $(SERVER_DIR) && make runestone-ps'
server-up:
	$(SSH) 'cd $(SERVER_DIR) && make up'
server-stop:
	$(SSH) 'cd $(SERVER_DIR) && make stop'
server-rm:
	$(SSH) 'cd $(SERVER_DIR) && make rm'
server-pgadmin-restart:
	$(SSH) 'cd $(SERVER_DIR) && make pgadmin-restart'
server-runestone-restart:
	$(SSH) 'cd $(SERVER_DIR) && make runestone-restart'
server-runestone-rm:
	$(SSH) 'cd $(SERVER_DIR) && make runestone-rm'
server-runestone-image:
	$(SSH) 'cd $(SERVER_DIR) && make runestone-image'
server-runestone-exec-bash:
	$(SSH) 'cd $(SERVER_DIR) && make runestone-exec-bash'
server-full-restart:
	$(SSH) 'cd $(SERVER_DIR) && make full-restart'
server-logs:
	$(SSH) 'cd $(SERVER_DIR) && make logs'
server-logsf:
	$(SSH) 'cd $(SERVER_DIR) && make logsf'
server-config:
	$(SSH) 'cd $(SERVER_DIR) && make config'
server-ps:
	$(SSH) 'cd $(SERVER_DIR) && make ps'
server-pgadmin-up:
	$(SSH) 'cd $(SERVER_DIR) && make pgadmin-up'
server-pgadmin-rm:
	$(SSH) 'cd $(SERVER_DIR) && make pgadmin-rm'
server-db-restart:
	$(SSH) 'cd $(SERVER_DIR) && make db-restart'


