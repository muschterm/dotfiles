# Add dotfiles /bin to PATH
export PATH="$DOTFILES_DIR/bin:$PATH"

if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
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

		if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1 && [ -f "/etc/sudoers.d/$(whoami)" ]; then
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
elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
	if command -v brew >/dev/null 2>&1; then
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
		# if [ ! -d "${local_brew_prefix}/opt/jq/bin" ]; then
		# 	cat <<-HERE
		# 		Homebrew 'jq' not installed!

		# 	HERE

		# 	brew install jq

		# 	cat <<-HERE
		# 		Homebrew 'jq' installed!

		# 	HERE
		# fi

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

		unset local_brew_prefix
	fi

	if [ -n "$BASH_VERSION" ]; then
		# Git
		[ -r "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash" ] && . "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
	fi
fi
