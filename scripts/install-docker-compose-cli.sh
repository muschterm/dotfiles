#!/usr/bin/env zsh

if [ "$(whoami)" != "root" ]; then
	echo Please run this script using sudo or as root.
	exit
fi

: ${VERSION:="2.23.3"}

if [ "$(print-distro)" = "alpine" ]; then
	cat <<-HERE
		For alpine, the following dependency packages are needed: py-pip, python3-dev, \
		libffi-dev, openssl-dev, gcc, libc-dev, rust, cargo and make."
	HERE
fi

if command -v curl >/dev/null; then
	curl -L "https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
else
	printf -- "Cannot install docker-compose - missing curl.\n"
fi
