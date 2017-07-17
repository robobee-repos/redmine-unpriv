include ../utils/Makefile.help
include ../utils/Makefile.functions

NAME := redmine-unpriv

test: ##@targets Starts test containers.
	docker-compose -p ${NAME} -f test.yaml up
.PHONY: up

stop: ##@targets Stops test containers.
	docker-compose -p ${NAME} -f test.yaml stop

clean: stop ##@targets Removes docker containers and created files.
	docker-compose -p ${NAME} -f test.yaml rm

