include ../utils/Makefile.help
include ../utils/Makefile.functions

NAME := redmine-keycloak
VOLUMES := html bundle db dbkeycloak

test: setup ##@targets Starts test containers.
	docker-compose -p $(NAME) -f test.yaml up
.PHONY: up

stop: ##@targets Stops test containers.
	docker-compose -p $(NAME) -f test.yaml stop

rm: stop ##@targets Removes docker containers and created files.
	docker-compose -p $(NAME) -f test.yaml rm -f

clean: stop rm ##@targets Removes docker containers and created files.
	sudo rm -rf root

clean-redmine: stop ##@targets Removes docker containers and created files.
	docker-compose -p $(NAME) -f test.yaml rm -f redmine
	sudo rm -rf root/html root/bundle

setup:
	for dir in $(VOLUMES); do \
	mkdir -p root/$${dir}; \
	sudo chmod o+rwX root/$${dir}; \
	done
.PHONY: setup
