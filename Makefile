RELEASE := $(if $(RELEASE),$(RELEASE),dev)
REPOSITORY := nosferatu

.PHONY: build
build-release: build-start \
	build-info \
	docker-build \
	docker-tag

.PHONY: build-start
build-start:
	$(if $(value BUILD_NUMBER),,$(error Error: BUILD_NUMBER is required))
	$(info [INF] Started build BUILD_NUMBER=$(BUILD_NUMBER))

.PHONY: build-info
build-info:
	$(info [INF] Creating build info file)
	rm -f build.info
	echo [build] >> build.info
	echo date=$(shell date +%FT%T) >> build.info
	echo number=$(BUILD_NUMBER) >> build.info
	echo [git] >> build.info
	echo commit=$(shell git rev-parse HEAD) >> build.info

.PHONY: docker-build
docker-build:
	$(info [INF] Building docker image)
	DOCKER_BUILDKIT=1 docker build --target prod -t "$(REPOSITORY):$(BUILD_NUMBER)" .

.PHONY: docker-tag
docker-tag:
	$(info [INF] Tagging: build number)
	docker tag "$(REPOSITORY):$(BUILD_NUMBER)" "$(ACCOUNT)/$(REPOSITORY):$(RELEASE)"

	$(info [INF] Tagging: latest)
	docker tag "$(REPOSITORY):$(BUILD_NUMBER)" "$(ACCOUNT)/$(REPOSITORY):$(BUILD_NUMBER)"