: ${DF_SETUP_DOCKER:="false"}
if [ "${DF_SETUP_DOCKER}" = "true" ]; then
	: ${DOCKER_DOTFILES_DIR:="$DF_SOFTWARE_HOME/docker"}

	# completions
	if [ -n "$ZSH_VERSION" ]; then
		alias set-completions-docker="docker completion zsh> \"$DOCKER_DOTFILES_DIR/completions/_docker\""

		if [ ! -f "$DOCKER_DOTFILES_DIR/completions/_docker" ]; then
			mkdir -p "$DOCKER_DOTFILES_DIR/completions"
			docker completion zsh > "$DOCKER_DOTFILES_DIR/completions/_docker"

			cat <<-HERE
				# after upgrading docker, run to ensure zsh completions are accurate:
				set-completions-docker
			HERE
		fi

		export FPATH="$DOCKER_DOTFILES_DIR/completions:$FPATH"
	elif [ -n "$BASH_VERSION" ]; then
		alias set-completions-docker="docker completion bash> \"$HOME/.local/share/bash-completion/completions/docker\""

		if [ ! -f "$HOME/.local/share/bash-completion/completions/docker" ]; then
			mkdir -p "$HOME/.local/share/bash-completion/completions"
			docker completion bash > "$HOME/.local/share/bash-completion/completions/docker"

			cat <<-HERE
				# after upgrading docker, run to ensure bash completions are accurate:
				set-completions-docker
			HERE
		fi
	fi
fi
