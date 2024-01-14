#!/usr/bin/env zsh

if command -v apt >/dev/null; then
	if docker buildx version &>/dev/null; then
		printf -- "Docker Buildx already installed.\n\n"

		docker buildx version

		cat <<-HERE

			Update using APT:

			  $([ "$(whoami)" != "root" ] && printf -- "sudo ")apt update
			  $([ "$(whoami)" != "root" ] && printf -- "sudo ")apt upgrade
		HERE
	else
		cat <<-HERE
			Please install Docker Buildx using APT:

			  $([ "$(whoami)" != "root" ] && printf -- "sudo ")apt install docker-buildx-plugin
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

: ${DOCKER_BUILDX_VERSION:="2.24.0"}

if command -v curl >/dev/null; then
	curl -L "https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/docker-buildx-$(uname -s)-$(uname -m)" -o "$DOCKER_CONFIG/cli-plugins/docker-buildx"
	chmod +x "$DOCKER_CONFIG/cli-plugins/docker-buildx"
else
	printf -- "Cannot install docker-buildx - missing curl.\n"
fi
