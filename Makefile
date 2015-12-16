.PHONY: build remove start stop state bash

cmd=docker-compose
step=----------------

build: remove
	@echo "$(step) Building Logstash Forwarder $(step)"
	@$(cmd) build

remove:
	@echo "$(step) Removing Logstash Forwarder $(step)"
	@$(cmd) rm -f

start:
	@echo "$(step) Starting Logstash Forwarder $(step)"
	@$(cmd) up -d forwarder

stop:
	@echo "$(step) Stopping Logstash Forwarder $(step)"
	@$(cmd) stop

state:
	@$(cmd) ps

bash:
	@$(cmd) run --rm forwarder bash

logs:
	@$(cmd) logs
