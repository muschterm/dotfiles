#!/usr/bin/env zsh

if command -v apt >/dev/null; then
	if docker compose version &>/dev/null; then
		printf -- "Docker Compose already installed.\n\n"

		docker compose version

		cat <<-HERE

			Update using APT:

			  $([ "$(whoami)" != "root" ] && printf -- "sudo ")apt update
			  $([ "$(whoami)" != "root" ] && printf -- "sudo ")apt upgrade
		HERE
	else
		cat <<-HERE
			Please install Docker Compose using APT:

			  $([ "$(whoami)" != "root" ] && printf -- "sudo ")apt install docker-compose-plugin
		HERE
	fi

	exit
fi

: ${DOCKER_CONFIG:="$HOME/.docker"}

if [ "$(whoami)" = "root" ]; then
	if [ "$(print-distro)" = "alpine" ]; then
		DOCKER_CONFIG="/usr/local/libexec/docker"
	else
		DOCKER_CONFIG="/usr/local/lib/docker"
	fi
fi

mkdir -p "$DOCKER_CONFIG/cli-plugins"

: ${DOCKER_COMPOSE_VERSION:="2.24.0"}

if command -v curl >/dev/null; then
	curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
	chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"
else
	printf -- "Cannot install docker-compose - missing curl.\n"
fi
