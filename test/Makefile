include ../utils/Makefile.help
include ../utils/Makefile.functions

NAME := redmine

test: setup ##@targets Starts test containers.
	docker-compose -p $(NAME) -f test.yaml up
.PHONY: up

stop: ##@targets Stops test containers.
	docker-compose -p $(NAME) -f test.yaml stop

clean: stop ##@targets Removes docker containers and created files.
	docker-compose -p $(NAME) -f test.yaml rm -f
	sudo rm -rf root

setup:
	mkdir -p root/html
	mkdir -p root/db
	chmod o+rwX root/html
	chmod o+rwX root/db
.PHONY: setup
