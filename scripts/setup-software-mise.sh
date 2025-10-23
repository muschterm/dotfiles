# https://mise.jdx.dev/installing-mise.html

: ${DF_SETUP_MISE:="true"}
if [ "${DF_SETUP_MISE}" = "true" ]; then
	export MISE_HOME="$DF_SOFTWARE_HOME/mise"
	export PATH="$MISE_HOME/bin:$PATH"
	export MISE_CONFIG_DIR="$DOTFILES_DIR/.config/mise"
	export MISE_CACHE_DIR="$MISE_HOME/cache"
	export MISE_STATE_DIR="$MISE_HOME/state"
	export MISE_DATA_DIR="$MISE_HOME/data"

	if ! command -v mise >/dev/null; then
		cat <<-HERE
			Installing Mise! into "$MISE_HOME"...
		HERE

		mkdir -p "$MISE_HOME/bin"

		(
			curl https://mise.run | MISE_INSTALL_PATH="$MISE_HOME/bin/mise" sh
		)
	fi

	if [ -n "$ZSH_VERSION" ]; then
		# completions
		alias set-completions-mise="mise completion zsh > \"$MISE_HOME/completions/_mise\""

		if [ ! -f "$MISE_HOME/completions/_mise" ]; then
			mkdir -p "$MISE_HOME/completions"
			mise completion zsh > "$MISE_HOME/completions/_mise"

			cat <<-HERE
				# after upgrading mise, run to ensure zsh completions are accurate:
				set-completions-mise
			HERE
		fi

		export FPATH="$MISE_HOME/completions:$FPATH"

		eval "$(mise activate zsh)"
	elif [ -n "$BASH_VERSION" ]; then
		# completions
		alias set-completions-mise="mise completion bash > \"$HOME/.local/share/bash-completion/completions/mise\""

		if [ ! -f "$HOME/.local/share/bash-completion/completions/mise" ]; then
			mkdir -p "$HOME/.local/share/bash-completion/completions"
			mise completion bash > "$HOME/.local/share/bash-completion/completions/mise"

			cat <<-HERE
				# after upgrading mise, run to ensure bash completions are accurate:
				set-completions-mise
			HERE
		fi

		eval "$(mise activate bash)"
	fi

fi
