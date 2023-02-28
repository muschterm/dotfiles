#!/usr/bin/env zsh

###############################################
#
# User - Allow container to use the same user as the host.
#   - Requires the container uses the specific scripts/docker-entrypoint.sh.
#
###############################################

if ! command -v docker > /dev/null; then
	return 0;
fi

is_docker_desktop=0
if [ "$(docker version --format='{{.Server.Platform.Name}}' 2>/dev/null | grep "Desktop" | wc -l)" = "1" ]; then
	is_docker_desktop=1
fi

local docker_user="$(whoami)"
local docker_user_home="/home/$docker_user"
local host_uid="$(id -u $docker_user)"
local host_gid="$(id -g $docker_user)"
# MacOS has a rediculously high ID value; just let the container
# default it.  MacOS doesn't need the user ID hack due to the
# type of file system used internally to the container.
if [ "$(uname -s)" = "Darwin" ]; then
	# if [ $HOST_UID -gt 9999 ] || [ $HOST_GID -gt 9999 ]; then
	# 	host_uid=
	# 	host_gid=
	# fi
	host_uid=
	host_gid=
fi

local docker_user_options=$(
	cat <<- HERE
	-e=DOCKER_USER=$docker_user \
	-e=HOST_UID=$host_uid \
	-e=HOST_GID=$host_gid
	HERE
)

if [ "$(uname -s)" = "Linux" ]; then
	local host_docker_gid="$(getent group | grep "^docker" | awk -F ":" '{ print $3 }')"
	docker_user_options=$(
		cat <<- HERE
		$docker_user_options \
		-e="HOST_DOCKER_GID=$host_docker_gid"
		HERE
	)
	unset host_docker_gid
fi

alias -g docker.user="$docker_user_options"
unset docker_user_options

local docker_build_user_options=$(
	cat <<- HERE
	--build-arg DOCKER_USER=$docker_user \
	--build-arg HOST_UID=$host_uid \
	--build-arg HOST_GID=$host_gid
	HERE
)

alias -g docker.build.user="$docker_build_user_options"
unset docker_build_user_options

unset host_uid
unset host_gid

local docker_build_proxy_options=$(
	cat <<- HERE
	--build-arg http_proxy \
	--build-arg https_proxy \
	--build-arg no_proxy
	HERE
)

alias -g docker.build.proxy="$docker_build_proxy_options"
unset docker_build_proxy_options

###############################################
#
# GUI - Allow container to display graphics.
#
###############################################

# Add helpful environment variables to match the host scale if using GDK apps
local docker_gui_options=$(
	cat <<- HERE
	$docker_gui_options \
	-e=GDK_SCALE -e=GDK_DPI_SCALE
	HERE
)

# Map the localtime; this ensure accurate time in the container when running
# images such as firefox.
if [ -f "/etc/localtime" ]; then 
	local localtime_var="/etc/localtime"
	if [ "$(uname -s)" = "Darwin" ]; then
		# MacOS /etc/localtime is a symlink
		localtime_var="$(readlink /etc/localtime)"
	fi
	
	docker_gui_options=$(
		cat <<- HERE
		$docker_gui_options \
		--mount type="bind",src="${localtime_var}",dst="/etc/localtime",readonly
		HERE
	)
	unset localtime_var
fi

# For OS's that have an .X11 socket.
if [ -d "/tmp/.X11-unix" ]; then
	docker_gui_options=$(
		cat <<- HERE
		$docker_gui_options \
		--mount type="bind",src="/tmp/.X11-unix",dst="/tmp/.X11-unix",readonly
		HERE
	)
fi

# Map the machine-id; this is necessary sometimes depending on some graphics
if [ -f "/etc/machine-id" ]; then
	docker_gui_options=$(
		cat <<- HERE
		$docker_gui_options \
		--mount type="bind",src="/etc/machine-id",dst="/etc/machine-id",readonly
		HERE
	)
fi

if ((is_docker_desktop)); then
	docker_gui_options=$(
		cat <<- HERE
		$docker_gui_options \
		-e "DISPLAY=host.docker.internal:0"
		HERE
	)
elif [ "$(uname -s)" = "Linux" ]; then
	docker_gui_options=$(
		cat <<- HERE
		$docker_gui_options \
		-e="DISPLAY=unix${DISPLAY}"
		HERE
	)
fi

alias -g docker.gui="$docker_gui_options"
unset docker_gui_options

###############################################
#
# Docker Socket - Allow container to use Docker CLI.
#
###############################################

if ((is_docker_desktop)); then
	if [ "$(uname -s)" = "Linux" ]; then
		if [ "$DF_WSL" = "true" ]; then
			alias -g docker.sock="-v $HOME/.docker/run/docker-cli-api.sock:/var/run/docker.sock"
		else
			alias -g docker.sock="-v $HOME/.docker/desktop/docker.sock:/var/run/docker.sock"
		fi
	elif [ "$(uname -s)" = "Darwin" ]; then
		alias -g docker.sock="-v $HOME/.docker/run/docker.sock:/var/run/docker.sock"
	fi
else
	alias -g docker.sock="-v /var/run/docker.sock:/var/run/docker.sock"
fi

###############################################
#
# SSH - Share SSH configuration with the container.
#
###############################################

local docker_ssh_options=$(
	cat <<- HERE
	--mount type="bind",src="$HOME/.ssh",dst="$docker_user_home/.ssh"
	HERE
)

alias -g docker.ssh="$docker_ssh_options"
unset docker_ssh_options

###############################################
#
# AWS - Share AWS CLI configuration with the container.
#
###############################################

local docker_aws_options=$(
	cat <<- HERE
	-e AWS_ACCESS_KEY_ID \
	-e AWS_SECRET_ACCESS_KEY \
	-e AWS_SESSION_TOKEN \
	-e AWS_DEFAULT_REGION \
	-e AWS_DEFAULT_OUTPUT \
	-e AWS_PROFILE \
	-e AWS_CA_BUNDLE \
	-e AWS_SHARED_CREDENTIALS_FILE \
	-e AWS_CONFIG_FILE \
	-e AWS_PROFILE \
	--mount type="bind",src="$HOME/.aws",dst="$docker_user_home/.aws"
	HERE
)

alias -g docker.aws="$docker_aws_options"
unset docker_aws_options

###############################################
#
# 'docker' function overrides default docker command
# to run with user and force amd64 for Mac Silicon.
#
###############################################

DF_DOCKER_LOCATION=$(which docker)

docker() {
	local command=("$DF_DOCKER_LOCATION" "$1")

	if [ "$DF_OS" = "$DF_OS_MACOS" ] && [ "$DF_ARCH" = "$DF_ARCH_ARM64" ]; then
		case "$1" in
			"build" | "create" | "run" )
				command+=("--platform" "linux/amd64")
				;;
		esac
	fi

	case "$1" in
		"build" )
			command+=(docker.build.user docker.build.proxy)
			;;
	esac

	case "$1" in
		"create" | "run" )
			command+=(docker.user)
			;;
	esac

	command+=("${@:2}")

	"${command[@]}"
}

###############################################
#
# 'docker run' alias to run with graphics support.
#   - Also ensures MacOS updates xhost.
#
###############################################

alias docker.run.gui="if [ "$(uname -s)" = "Darwin" ] && [ "$(which xhost &>/dev/null; printf -- "$?")" = "0" ]; then xhost + 127.0.0.1; fi; docker run docker.gui"

unset docker_user
unset docker_user_home
