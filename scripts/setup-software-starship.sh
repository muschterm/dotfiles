: ${DF_SETUP_STARSHIP:="true"}
if [ "${DF_SETUP_STARSHIP}" = "true" ]; then
	export STARSHIP_HOME="$DF_SOFTWARE_HOME/starship"
	export PATH="$STARSHIP_HOME/bin:$PATH"
	export STARSHIP_CONFIG="$DOTFILES_DIR/.config/starship.toml"

	if ! command -v starship >/dev/null; then
		cat <<-HERE
			Installing Starship! into "$STARSHIP_DIR"...
		HERE

		mkdir -p "$STARSHIP_HOME/bin"

		(
			curl -sS https://starship.rs/install.sh | sh -s -- -b "$STARSHIP_HOME/bin"
		)
	fi

	if [ -n "$ZSH_VERSION" ]; then
		# completions
		alias set-completions-starship="starship completions zsh> \"$STARSHIP_HOME/completions/_starship\""

		if [ ! -f "$STARSHIP_HOME/completions/_starship" ]; then
			mkdir -p "$STARSHIP_HOME/completions"
			starship completions zsh > "$STARSHIP_HOME/completions/_starship"

			cat <<-HERE
				# after upgrading starship, run to ensure zsh completions are accurate:
				set-completions-starship
			HERE
		fi

		export FPATH="$STARSHIP_HOME/completions:$FPATH"

		eval "$(starship init zsh)"
	elif [ -n "$BASH_VERSION" ]; then
		# completions
		alias set-completions-docker="starship completions bash> \"$HOME/.local/share/bash-completion/completions/starship\""

		if [ ! -f "$HOME/.local/share/bash-completion/completions/starship" ]; then
			mkdir -p "$HOME/.local/share/bash-completion/completions"
			starship completions bash > "$HOME/.local/share/bash-completion/completions/starship"

			cat <<-HERE
				# after upgrading starship, run to ensure bash completions are accurate:
				set-completions-starship
			HERE
		fi

		eval "$(starship init bash)"
	fi

fi
