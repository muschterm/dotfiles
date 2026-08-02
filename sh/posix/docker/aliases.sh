###############################################
#
# User - Allow container to use the same user as the host.
#   - Requires the container uses the specific scripts/docker-entrypoint.sh.
#
###############################################

# Drop any previously defined wrapper so re-sourcing resolves the real binary
# (zsh's `which`/`command -v` report the function otherwise).
unset -f docker >/dev/null 2>&1

if ! command -v docker >/dev/null; then
	return 0
fi

is_docker_desktop=0
if [ "$(docker version --format='{{.Server.Platform.Name}}' 2>/dev/null | grep "Desktop" | wc -l | tr -d "[:space:]")" = "1" ]; then
	is_docker_desktop=1
fi

docker_user="$(whoami)"
docker_user_home="/home/$docker_user"
host_uid="$(id -u "$docker_user")"
host_gid="$(id -g "$docker_user")"
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

docker_user_options=(
	"-e=DOCKER_USER=$docker_user"
	"-e=HOST_UID=$host_uid"
	"-e=HOST_GID=$host_gid"
)

if [ "$(uname -s)" = "Linux" ]; then
	host_docker_gid="$(getent group | grep "^docker" | awk -F ":" '{ print $3 }')"
	docker_user_options+=("-e=HOST_DOCKER_GID=$host_docker_gid")
	unset host_docker_gid
fi

docker_build_user_options=(
	"--build-arg" "DOCKER_USER=$docker_user"
	"--build-arg" "HOST_UID=$host_uid"
	"--build-arg" "HOST_GID=$host_gid"
)

unset host_uid
unset host_gid

docker_build_proxy_options=(
	"--build-arg" "http_proxy"
	"--build-arg" "https_proxy"
	"--build-arg" "no_proxy"
)

###############################################
#
# GUI - Allow container to display graphics.
#
###############################################

# Add helpful environment variables to match the host scale if using GDK apps
docker_gui_options=(
	"-e=GDK_SCALE"
	"-e=GDK_DPI_SCALE"
)

# Map the localtime; this ensure accurate time in the container when running
# images such as firefox.
if [ -f "/etc/localtime" ]; then
	localtime_var="/etc/localtime"
	if [ "$(uname -s)" = "Darwin" ]; then
		# MacOS /etc/localtime is a symlink
		localtime_var="$(readlink /etc/localtime)"
	fi

	docker_gui_options+=(
		"--mount" "type=bind,src=${localtime_var},dst=/etc/localtime,readonly"
	)
	unset localtime_var
fi

# For OS's that have an .X11 socket.
if [ -d "/tmp/.X11-unix" ]; then
	docker_gui_options+=(
		"--mount" "type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix,readonly"
	)
fi

# Map the machine-id; this is necessary sometimes depending on some graphics
if [ -f "/etc/machine-id" ]; then
	docker_gui_options+=(
		"--mount" "type=bind,src=/etc/machine-id,dst=/etc/machine-id,readonly"
	)
fi

if ((is_docker_desktop)); then
	docker_gui_options+=("-e" "DISPLAY=host.docker.internal:0")
elif [ "$(uname -s)" = "Linux" ]; then
	docker_gui_options+=("-e=DISPLAY=unix${DISPLAY}")
fi

###############################################
#
# Docker Socket - Allow container to use Docker CLI.
#
###############################################

docker_sock_options=()
if ((is_docker_desktop)); then
	if [ "$(uname -s)" = "Linux" ]; then
		if [ "$DF_WSL" = "true" ]; then
			docker_sock_options=("-v" "$HOME/.docker/run/docker-cli-api.sock:/var/run/docker.sock")
		else
			docker_sock_options=("-v" "$HOME/.docker/desktop/docker.sock:/var/run/docker.sock")
		fi
	elif [ "$(uname -s)" = "Darwin" ]; then
		docker_sock_options=("-v" "$HOME/.docker/run/docker.sock:/var/run/docker.sock")
	fi
else
	docker_sock_options=("-v" "/var/run/docker.sock:/var/run/docker.sock")
fi

unset is_docker_desktop

###############################################
#
# SSH - Share SSH configuration with the container.
#
###############################################

docker_ssh_options=(
	"--mount" "type=bind,src=$HOME/.ssh,dst=$docker_user_home/.ssh"
)

###############################################
#
# AWS - Share AWS CLI configuration with the container.
#
###############################################

docker_aws_options=(
	"-e" "AWS_ACCESS_KEY_ID"
	"-e" "AWS_SECRET_ACCESS_KEY"
	"-e" "AWS_SESSION_TOKEN"
	"-e" "AWS_DEFAULT_REGION"
	"-e" "AWS_DEFAULT_OUTPUT"
	"-e" "AWS_PROFILE"
	"-e" "AWS_CA_BUNDLE"
	"-e" "AWS_SHARED_CREDENTIALS_FILE"
	"-e" "AWS_CONFIG_FILE"
	"--mount" "type=bind,src=$HOME/.aws,dst=$docker_user_home/.aws"
)

###############################################
#
# 'docker' function overrides default docker command
# to run with user and force amd64 for Mac Silicon.
#
###############################################

DF_DOCKER_LOCATION="$(command -v docker)"
: ${DF_FORCE_AMD64_DOCKER:="false"}

docker() {
	if [ $# -eq 0 ]; then
		"$DF_DOCKER_LOCATION"
		return
	fi

	local docker_command=("$DF_DOCKER_LOCATION" "$1")

	if [ "$DF_OS" = "$DF_OS_MACOS" ] && [ "$DF_ARCH" = "$DF_ARCH_ARM_64" ] && [ "$DF_FORCE_AMD64_DOCKER" = "true" ]; then
		case "$1" in
		"build" | "create" | "run")
			docker_command+=("--platform" "linux/amd64")
			;;
		esac
	fi

	case "$1" in
	"build")
		docker_command+=("${docker_build_user_options[@]}" "${docker_build_proxy_options[@]}")
		;;
	esac

	case "$1" in
	"create" | "run")
		docker_command+=("${docker_user_options[@]}")
		;;
	esac

	docker_command+=("${@:2}")

	"${docker_command[@]}"
}

###############################################
#
# 'docker run' wrapper to run with graphics support.
#   - Also ensures MacOS updates xhost.
#
###############################################

docker-run-gui() {
	if [ "$(uname -s)" = "Darwin" ] && command -v xhost >/dev/null; then
		xhost + 127.0.0.1
	fi

	docker run "${docker_gui_options[@]}" "$@"
}

unset docker_user
unset docker_user_home
