VERSION?=$$(git rev-parse --abbrev-ref HEAD)

requirements_frozen.txt requirements.nix requirements_override.nix: requirements.txt
	pypi2nix -V 3.6 -r $^

.PHONY: all
all: requirements_frozen.txt requirements.nix requirements_override.nix default.nix
	nix-build -K .

.PHONY: clean
clean:
	rm -rf .cache result requirements_frozen.txt

.PHONY: bump-requirements
bump-requirements: clean requirements_frozen.txt

.PHONY: dockerize
dockerize: dockerize.nix
	docker load --input $$(nix-build dockerize.nix)


.PHONY: docker-push
docker-push:
	if [ -n "$$DOCKER_USERNAME" -a -n "$$DOCKER_PASSWORD" ]; then \
	  docker login -u "$${DOCKER_USERNAME}" -p "$${DOCKER_PASSWORD}"; \
	else \
	  docker login; \
	fi
	docker tag gbowyer/marge-bot:$$(cat version) gbowyer/marge-bot:$(VERSION)
	if [ "$(VERSION)" = "$$(cat version)" ]; then \
	  docker tag gbowyer/marge-bot:$$(cat version) gbowyer/marge-bot:latest; \
	  docker tag gbowyer/marge-bot:$$(cat version) gbowyer/marge-bot:stable; \
	  docker push gbowyer/marge-bot:stable; \
	  docker push gbowyer/marge-bot:latest; \
	fi
	docker push gbowyer/marge-bot:$(VERSION)
