#
# Generic Docker Container Makefile
#

# Configure the following to taste:

# Name of your application.  Don't put anything in here that doesn't
# belong in a directory path.
NAME := markfeit/mailman2

# Who's responsible for this container
MAINTAINER := Mark Feit <mfeit@notonthe.net>

# The base container for this one
FROM := oraclelinux:8-slim

# If this is defined, use supervisord to run programs.  Add files that
# start them up to ./supervisor/supervisor.d.  If NOT defined
# execute app/run instead.
SUPERVISED := 1

# Additional arguments to pass to docker run
RUN_ARGS := \
	--volume=/home/mfeit/hole/mailman-data:/mailman \
	--volume=/home/mfeit/work/docker-mailman2:/work
## TODO: --publish=1234:1234
## TODO: Remove share of /work

#
# No user-serviceable parts beyond this point.
#


# Make sure NAME can pass as a directory.
NAME_PARTS := $(subst /, ,$(NAME))
ifneq ($(filter .,$(NAME_PARTS))$(filter ..,$(NAME_PARTS)),)
$(error Invalid characters in NAME.  No . or .. allowed.)
endif


default: run

DOCKERFILE=Dockerfile
DOCKERFILE_PARTS=$(DOCKERFILE).d

$(DOCKERFILE)::
	@echo '#'
	@echo '# Generating Dockerfile'
	@echo '#'
	@echo
ifdef SUPERVISED
	@echo This container is supervised.
	@echo
	rm -f $(DOCKERFILE_PARTS)/98-app
	ln -s ../supervisor/Dockerfile $(DOCKERFILE_PARTS)/98-supervisor
else
	@echo This container runs a single program.
	@echo
	rm -f $(DOCKERFILE_PARTS)/98-supervisor
	ln -s ../app/Dockerfile $(DOCKERFILE_PARTS)/98-app
endif
	find -L $(DOCKERFILE_PARTS) -type f -print \
	| sort \
	| xargs cat \
	> $@
	sed -i \
		-e 's|__NAME__|$(NAME)|g' \
		-e 's|__MAINTAINER__|$(MAINTAINER)|g' \
		-e 's|__FROM__|$(FROM)|g' \
		$@
TO_CLEAN += \
	$(DOCKERFILE) \
	$(DOCKERFILE_PARTS)/98-app \
	$(DOCKERFILE_PARTS)/98-supervisor



# Run the container interactively
run: clean $(DOCKERFILE)
	@echo
	@echo '#'
	@echo '# Building Container'
	@echo '#'
	@echo
	docker build -t $(NAME) .
	@echo
	@echo '#'
	@echo '# Running Container'
	@echo '#'
	@echo
	docker run --rm -it $(RUN_ARGS) $(NAME)


# Prepare for a release by generating the Dockerfile
release:
	$(MAKE) clean
	$(MAKE) $(DOCKERFILE)


# Start a shell to the container if it's running.
shell sh:
	@docker exec -it `docker ps | awk -v "NAME=localhost/$(NAME):latest" '$$2 == NAME { print $$1 }'` sh


# Get rid of build by-products
clean:
	rm -rf $(TO_CLEAN)
	find . -name '*~' -print0 | xargs -0 rm -rf
