: ${DF_SETUP_DOCKER:="false"}
if [ "${DF_SETUP_DOCKER}" = "true" ]; then
	# completions
	if [ -n "$ZSH_VERSION" ]; then
		alias set-completion-docker="docker completion zsh> \"$HOME/.docker/completions/_docker\""

		if [ ! -f "$HOME/.docker/completions/_docker" ]; then
			mkdir -p "$HOME/.docker/completions"
			docker completion zsh > "$HOME/.docker/completions/_docker"

			cat <<-HERE
				# after upgrading docker, run to ensure zsh completions are accurate:
				set-completion-docker
			HERE
		fi

		export FPATH="$HOME/.docker/completions:$FPATH"
	elif [ -n "$BASH_VERSION" ]; then
		alias set-completion-docker="docker completion bash> \"$HOME/.local/share/bash-completion/completions/docker\""

		if [ ! -f "$HOME/.local/share/bash-completion/completions/docker" ]; then
			mkdir -p "$HOME/.local/share/bash-completion/completions"
			docker completion bash > "$HOME/.local/share/bash-completion/completions/docker"

			cat <<-HERE
				# after upgrading docker, run to ensure bash completions are accurate:
				set-completion-docker
			HERE
		fi
	fi
fi
