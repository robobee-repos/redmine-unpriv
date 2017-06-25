include ../utils/Makefile.help
include ../utils/Makefile.functions

up: ##@targets Starts docker compose.
	docker-compose -f redmine-unpriv-test.yaml up
.PHONY: up

stop: ##@targets Stops docker containers.
	docker-compose -f redmine-unpriv-test.yaml stop

clean: stop ##@targets Removes docker containers and created files.
	docker-compose -f redmine-unpriv-test.yaml rm

