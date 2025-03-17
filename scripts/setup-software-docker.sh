: ${DF_SETUP_DOCKER:="false"}
if [ "${DF_SETUP_DOCKER}" = "true" ]; then
	# completions
	if [ -n "$ZSH_VERSION" ]; then
		if [ ! -f "$HOME/.docker/completions/_docker" ]; then
			mkdir -p "$HOME/.docker/completions"
			docker completions zsh > "$HOME/.docker/completions/_docker"

			cat <<-HERE
				# after upgrading docker, run to ensure zsh completions are accurate:
				docker completions zsh > "$HOME/.docker/completions/_docker"
			HERE
		fi

		export FPATH="$HOME/.docker/completions:$FPATH"
	elif [ -n "$BASH_VERSION" ]; then
		if [ ! -f "$HOME/.local/share/bash-completion/completions/docker" ]; then
			mkdir -p "$HOME/.local/share/bash-completion/completions"
			docker completions bash > "$HOME/.local/share/bash-completion/completions/docker"

			cat <<-HERE
				# after upgrading docker, run to ensure bash completions are accurate:
				docker completions bash > "$HOME/.local/share/bash-completion/completions/docker"
			HERE

		fi
	fi
fi
