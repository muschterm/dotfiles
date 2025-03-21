# allow vi editing
# set -o vi

: ${DOTFILES_DIR:="/opt/dotfiles"}

###############################################################################
# Variables                                                                   #
###############################################################################
DF_OS=
DF_OS_LINUX="linux"
DF_OS_MACOS="macos"
DF_OS_WINDOWS="windows"
DF_WSL="false"
case "$(uname -r)" in
*microsoft*)
	DF_WSL="true"
	;;
*) ;;
esac

case "$(uname -s)" in
"Linux")
	DF_OS=$DF_OS_LINUX

	[ -z "$DF_DOWNLOADS_HOME" ] && export DF_DOWNLOADS_HOME="$HOME/.dotfiles.d/downloads"
	[ -z "$DF_SOFTWARE_HOME" ] && export DF_SOFTWARE_HOME="$HOME/.dotfiles.d/opt"
	[ -z "$DF_APP_HOME" ] && export DF_APP_HOME="$HOME/.dotfiles.d/app"
	;;
"Darwin")
	DF_OS=$DF_OS_MACOS

	[ -z "$DF_DOWNLOADS_HOME" ] && export DF_DOWNLOADS_HOME="$HOME/.dotfiles.d/downloads"
	[ -z "$DF_SOFTWARE_HOME" ] && export DF_SOFTWARE_HOME="$HOME/.dotfiles.d/opt"
	[ -z "$DF_APP_HOME" ] && export DF_APP_HOME="/Applications"
	;;
"MSYS"* | "MINGW"* | "CYGWIN"*)
	DF_OS=$DF_OS_WINDOWS
	: ${DEV_WINDOWS_DRIVELETTER:="c"}

	[ -z "$DF_DOWNLOADS_HOME" ] && export DF_DOWNLOADS_HOME="$USERPROFILE/Downloads"
	[ -z "$DF_SOFTWARE_HOME" ] && export DF_SOFTWARE_HOME="/$DEV_WINDOWS_DRIVELETTER/dotfiles/opt"
	[ -z "$DF_APP_HOME" ] && export DF_APP_HOME="/$DEV_WINDOWS_DRIVELETTER/dotfiles/app"
	;;
esac

DF_ARCH=
DF_ARCH_ARM_64="arm_64"
DF_ARCH_ARM_32="arm_32"
DF_ARCH_X86_64="x86_64"
DF_ARCH_X86_32="x86_32"

case "$(uname -m)" in
arm64 | aarch64 | armv8*)
	DF_ARCH="$DF_ARCH_ARM_64"
	;;
armv7* | armv6*)
	DF_ARCH="$DF_ARCH_ARM_32"
	;;
x86_64 | amd64)
	DF_ARCH="$DF_ARCH_X86_64"
	;;
i*86)
	DF_ARCH="$DF_ARCH_X86_32"
	;;
esac

[ ! -d "$DF_DOWNLOADS_HOME" ] && mkdir -p "$DF_DOWNLOADS_HOME"
[ ! -d "$DF_SOFTWARE_HOME" ] && mkdir -p "$DF_SOFTWARE_HOME"

###############################################################################
# Aliases                                                                     #
###############################################################################
if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
	alias open="xdg-open &>/dev/null"
	alias copy="xclip -selection clipboard"
elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
	alias copy="pbcopy"
fi

alias ls="ls -X --group-directories-first --color"
alias la="ls -AXl --group-directories-first --color"

. "$DOTFILES_DIR/scripts/setup-aliases-docker.sh"

###############################################################################
# Setup/Path                                                                  #
###############################################################################
if [ "$DF_OS" = "$DF_OS_LINUX" ] || [ "$DF_OS" = "$DF_OS_MACOS" ]; then
	if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
		local_user="$(whoami)"
		local_can_use_sudo="false"
		if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null; then
			local_can_use_sudo="true"
		fi

		if [ "$local_can_use_sudo" = "true" ] && [ ! -f "/etc/sudoers.d/${local_user}" ]; then
			printf -- "Setting up passwordless sudo!\n\n"

			sudo touch "/etc/sudoers.d/${local_user}"
			sudo chmod 0777 "/etc/sudoers.d/${local_user}"

			cat <<-HERE >"/etc/sudoers.d/${local_user}"
				${local_user} ALL=(ALL) NOPASSWD: ALL
			HERE

			sudo chmod 0440 "/etc/sudoers.d/${local_user}"
		fi

		if [ "$DF_WSL" = "true" ]; then
			# always start in linux home directory
			# the linux file system is better performing and where
			# most, if not all, WSL work should be done
			cd "$HOME"

			# only if not using Windows 11 WSLG capability
			if [ ! -d "/mnt/wslg" ]; then
				# display requires host IP address to connect to x server; this is due to WSL2
				export DISPLAY="$(cat "/etc/resolv.conf" | grep nameserver | awk -F " " '{print $2}'):0"
				export LIBGL_ALWAYS_INDIRECT=1
			fi

			if [ "$local_can_use_sudo" = "true" ]; then
				# Mount to /<driveletter> instead of just /mnt/<driveletter> - fixes Docker mapping issues (and is better)
				if [ -d "/mnt/c" ] && [ -d "/c" ]; then
					sudo mount -o bind /mnt/c /c
				fi

				if [ -d "/mnt/d" ] && [ -d "/d" ]; then
					sudo mount -o bind /mnt/d /d
				fi

				if [ -d "/mnt/e" ] && [ -d "/e" ]; then
					sudo mount -o bind /mnt/e /e
				fi

				if [ -d "/mnt/f" ] && [ -d "/f" ]; then
					sudo mount -o bind /mnt/f /f
				fi

				if [ -d "/mnt/g" ] && [ -d "/g" ]; then
					sudo mount -o bind /mnt/g /g
				fi
			fi
		fi

		unset local_can_use_sudo
	fi

	if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		: ${DF_DOCKER_APP_HOME:="/Applications/Docker.app"}
		if command -v brew >/dev/null; then
			local_brew_prefix="$(brew --prefix)"

			# GNU coreutils
			export PATH="${local_brew_prefix}/opt/coreutils/libexec/gnubin:$PATH"
			export MANPATH="${local_brew_prefix}/opt/coreutils/libexec/gnuman:$MANPATH"
			if [ ! -d "${local_brew_prefix}/opt/coreutils/libexec/gnubin" ]; then
				cat <<-HERE
					Homebrew 'coreutils' not installed!

				HERE

				brew install coreutils

				cat <<-HERE
					Homebrew 'coreutils' installed!

				HERE
			fi

			# GNU sed
			export PATH="${local_brew_prefix}/opt/gnu-sed/libexec/gnubin:$PATH"
			export MANPATH="${local_brew_prefix}/opt/gnu-sed/libexec/gnuman:$MANPATH"
			if [ ! -d "${local_brew_prefix}/opt/gnu-sed/libexec/gnubin" ]; then
				cat <<-HERE
					Homebrew 'gnu-sed' not installed!

				HERE

				brew install gnu-sed

				cat <<-HERE
					Homebrew 'gnu-sed' installed!

				HERE
			fi

			# GNU tar
			export PATH="${local_brew_prefix}/opt/gnu-tar/libexec/gnubin:$PATH"
			export MANPATH="${local_brew_prefix}/opt/gnu-tar/libexec/gnuman:$PATH"
			if [ ! -d "${local_brew_prefix}/opt/gnu-tar/libexec/gnubin" ]; then
				cat <<-HERE
					Homebrew 'gnu-tar' not installed!

				HERE

				brew install gnu-tar

				cat <<-HERE
					Homebrew 'gnu-tar' installed!

				HERE
			fi

			# gpg
			# if [ ! -d "${local_brew_prefix}/opt/gpg/bin" ]; then
			# 	cat <<- HERE
			# 	Homebrew 'gpg' not installed!

			# 	HERE

			# 	brew install gpg

			# 	cat <<- HERE
			# 	Homebrew 'gpg' installed!

			# 	HERE
			# fi

			# jq (for handling JSON)
			if [ ! -d "${local_brew_prefix}/opt/jq/bin" ]; then
				cat <<-HERE
					Homebrew 'jq' not installed!

				HERE

				brew install jq

				cat <<-HERE
					Homebrew 'jq' installed!

				HERE
			fi

			# python3
			# if [ ! -d "${local_brew_prefix}/opt/python@3" ]; then
			# 	cat <<-HERE
			# 		Homebrew 'python' not installed!

			# 	HERE

			# 	brew install python

			# 	cat <<-HERE
			# 		Homebrew 'python' installed!

			# 	HERE
			# fi

			# rq (for handling YAML and XML)
			# if [ ! -f "${local_brew_prefix}/bin/yq" ]; then
			# 	cat <<-HERE
			# 		pip 'yq' not installed!

			# 	HERE

			# 	pip3 install yq

			# 	cat <<-HERE
			# 		pip 'yq' installed!

			# 	HERE
			# fi

			if [ -n "$BASH_VERSION" ]; then
				[ -r "${local_brew_prefix}/etc/profile.d/bash_completion.sh" ] && . "${local_brew_prefix}/etc/profile.d/bash_completion.sh"
			fi

			# now handled by ./scripts/setup-software-docker.sh
			# if [ -n "$ZSH_VERSION" ]; then
			# 	if [ ! -f "${local_brew_prefix}/share/zsh/site-functions/_docker" ]; then
			# 		[ -r "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker.zsh-completion" ] && ln -s "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker.zsh-completion" "${local_brew_prefix}/share/zsh/site-functions/_docker"
			# 		[ -r "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-machine.zsh-completion" ] && ln -s "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-machine.zsh-completion" "${local_brew_prefix}/share/zsh/site-functions/_docker-machine"
			# 		[ -r "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-compose.zsh-completion" ] && ln -s "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-compose.zsh-completion" "${local_brew_prefix}/share/zsh/site-functions/_docker-compose"
			# 	fi
			# fi

			unset local_brew_prefix
		fi

		if [ -n "$BASH_VERSION" ]; then
			# now handled by ./scripts/setup-software-docker.sh
			# Docker
			# [ -r "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker.bash-completion" ] && . "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker.bash-completion"
			# [ -r "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-machine.bash-completion" ] && . "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-machine.bash-completion"
			# [ -r "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-compose.bash-completion" ] && . "${DF_DOCKER_APP_HOME}/Contents/Resources/etc/docker-compose.bash-completion"

			# Git
			[ -r "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash" ] && . "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
		fi
	fi

	# Add dotfiles /bin to PATH
	export PATH="$DOTFILES_DIR/bin:$PATH"
fi

###############################################################################
# Formatting                                                                  #
###############################################################################
. "$DOTFILES_DIR/scripts/setup-format.sh"
. "$DOTFILES_DIR/scripts/setup-format-ps1.sh"
. "$DOTFILES_DIR/scripts/setup-format-functions.sh"

###############################################################################
# Functions                                                                   #
###############################################################################
. "$DOTFILES_DIR/scripts/setup-functions.sh"

###############################################################################
# Software                                                                    #
###############################################################################
. "$DOTFILES_DIR/scripts/setup-software-docker.sh"
. "$DOTFILES_DIR/scripts/setup-software-sdkman.sh"
. "$DOTFILES_DIR/scripts/setup-software-java.sh"
. "$DOTFILES_DIR/scripts/setup-software-nodejs.sh"
. "$DOTFILES_DIR/scripts/setup-software-bun.sh"
. "$DOTFILES_DIR/scripts/setup-software-deno.sh"
. "$DOTFILES_DIR/scripts/setup-software-golang.sh"
. "$DOTFILES_DIR/scripts/setup-software-jb-toolbox.sh"
. "$DOTFILES_DIR/scripts/setup-software-vscode.sh"
. "$DOTFILES_DIR/scripts/setup-software-sublime.sh"
. "$DOTFILES_DIR/scripts/setup-software-zed.sh"
