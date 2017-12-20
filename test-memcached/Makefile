include ../utils/Makefile.help
include ../utils/Makefile.functions

NAME := redminememcached

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
	for p in html ; do \
	mkdir -p root/$$p; \
	chmod o+rwX root/$$p ; \
	done
.PHONY: setup
