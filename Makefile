PACKAGE ?= docker-openvpn
DOCKER ?= $(shell which docker || echo docker)
DOCKER_IMAGE ?= 367353094751.dkr.ecr.eu-west-1.amazonaws.com/$(shell echo $(PACKAGE) | tr A-Z a-z)
VERSION ?= $(shell git describe --abbrev=8 --always HEAD)
DOCKER_VARY ?= 
DOCKER_TAG ?= $(VERSION)$(if $(DOCKER_VARY),-$(DOCKER_VARY))
DOCKER_BUILD ?= $(DOCKER) image build
DOCKER_PUSH ?= $(DOCKER) image push
DOCKER_BUILD_FILE ?= Dockerfile$(if $(DOCKER_VARY),.$(DOCKER_VARY))
DOCKER_IMAGE ?= 367353094751.dkr.ecr.eu-west-1.amazonaws.com/batvoice$(if $(DOCKER_VARY),-$(DOCKER_VARY))
DOCKER_BUILD_OPTIONS ?= --build-arg IMAGE=$(DOCKER_IMAGE)

docker-aws-ecr-login:   ## Apply AWS credentials for the container registry to local docker.
	$(shell aws ecr get-login --no-include-email --region eu-west-1)
docker-build:   ## Build AMD64 version of docker image.
	$(DOCKER_BUILD) -f $(DOCKER_BUILD_FILE) $(DOCKER_BUILD_OPTIONS) -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
docker-build-arm:   ## Build ARM64 version of docker image.
	DOCKER_VARY=aarch64 $(MAKE) docker-build
docker-push: docker-aws-ecr-login ## Push AMD64 version of image to remote registry.
	$(DOCKER_PUSH) $(DOCKER_PUSH_OPTIONS) $(DOCKER_IMAGE):$(DOCKER_TAG)
docker-push-arm:   ## Push ARM64 version of image to remote registry.
	DOCKER_VARY=aarch64 $(MAKE) docker-push
help:   ## Show available commands.
	@echo "Available commands:"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?##[\s]?.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"}; {printf "	make \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo
