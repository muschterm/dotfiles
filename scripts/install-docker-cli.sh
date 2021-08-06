#!/usr/bin/env zsh

if [ "$(whoami)" != "root" ]; then
	echo Please run this script using sudo or as root.
	exit
fi

: ${DOCKER_VERSION:="20.10.8"}

arch="$(print-arch)"; \
case "$arch" in
	'x86_64')
		url="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"
		;;
	'armhf')
		url="https://download.docker.com/linux/static/stable/armel/docker-${DOCKER_VERSION}.tgz"
		;;
	'armv7')
		url="https://download.docker.com/linux/static/stable/armhf/docker-${DOCKER_VERSION}.tgz"
		;;
	'aarch64')
		url="https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VERSION}.tgz"
		;;
	*)
		echo >&2 "error: unsupported architecture ($arch)"
		exit 1
		;;
esac

if [ "$(which curl &>/dev/null; printf -- "$?")" = "0" ]; then
	curl -fsSL -o "$HOME/docker.tgz" "$url"
elif [ "$(which curl &>/dev/null; printf -- "$?")" = "0" ]; then
	wget -O "$HOME/docker.tgz" "$url"
else
	printf -- "Cannot install Docker CLI - missing curl or wget.\n"
fi

tar --extract \
	--file "$HOME/docker.tgz" \
	--strip-components 1 \
	--directory /usr/local/bin/

rm "$HOME/docker.tgz"
dockerd --version
docker --version
