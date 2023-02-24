#!/usr/bin/env sh

#
# To be used as the entrypoint for Docker containers that need:
#   - x11 display on the host (ie: use GUI programs)
#   - same user id and group id for when creating files in mounted volumes from the host
#
# Compatible with alpine and debian distros.
# 
# This is less needed when using Docker for Mac or Docker for Windows as that natively
# handles the privileges for the host user within the container.
#

: ${DOCKER_USER:="duser"}
: ${HOST_UID:="1000"}
: ${HOST_GID:="1000"}

distro="$(print-distro)"
if [ "$distro" = "alpine" ]; then
	addgroup -S -g $HOST_GID $DOCKER_USER
	adduser -S -D -u ${HOST_UID} -s /bin/sh -G $DOCKER_USER $DOCKER_USER

	if [ ! -z "$HOST_DOCKER_GID" ]; then
		addgroup -g $HOST_DOCKER_GID docker
		addgroup $DOCKER_USER docker
	fi
else
	# all other distros - debian, fedora, centos, redhat, etc.
	groupadd -r -g $HOST_GID $DOCKER_USER
	useradd -r -u $HOST_UID -s /bin/sh -g $DOCKER_USER $DOCKER_USER

	if [ ! -z "$HOST_DOCKER_GID" ]; then
		groupadd -g $HOST_DOCKER_GID docker
		usermod -a -G docker $DOCKER_USER
	fi
fi

mkdir -p "/home/${DOCKER_USER}"
touch "/home/${DOCKER_USER}/.zshrc"
chown -R "$DOCKER_USER:$DOCKER_USER" "/home/$DOCKER_USER"
mkdir -p "/run/user/$HOST_UID"
chown -R "$DOCKER_USER:$DOCKER_USER" "/run/user/$HOST_UID"

# Add no password sudo.
printf -- "$DOCKER_USER ALL=(ALL) NOPASSWD: ALL
" >> "/etc/sudoers.d/$DOCKER_USER"
chmod 0440 "/etc/sudoers.d/$DOCKER_USER"

if [ "$distro" = "alpine" ]; then
	exec su-exec $DOCKER_USER "$@"
else
	# Install gosu if not already part of the image. This is something
	# that should not be done and should be part of the image, but also
	# can be helpful during development.
	if [ "$(which gosu &>/dev/null; printf -- "$?")" = "0" ]; then
		apt-get update
		apt-get install -y gosu
		rm -rf /var/lib/apt/lists/*

		# Test that gosu installed properly.
		gosu nobody true
	fi

	exec gosu $DOCKER_USER "$@"
fi
