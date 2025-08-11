: ${DF_SETUP_DENO:="false"}
if [ "${DF_SETUP_DENO}" = "true" ]; then
	: ${DENO_INSTALL:="$HOME/.deno"}

	export PATH="$DENO_INSTALL/bin:$PATH"

	if [ ! -d "$DENO_INSTALL" ]; then
		cat <<-HERE
			Installing Deno into "$DENO_INSTALL"...
		HERE

		(
			curl -fsSL "https://deno.land/x/install/install.sh" | sh
		)
	fi

	# completions
	if [ -n "$ZSH_VERSION" ]; then
		alias set-completion-deno="deno completions zsh > \"$DENO_INSTALL/completions/_deno\""

		if [ ! -f "$DENO_INSTALL/completions/_deno" ]; then
			mkdir -p "$DENO_INSTALL/completions"
			deno completions zsh > "$DENO_INSTALL/completions/_deno"

			cat <<-HERE
				# after upgrading deno, run to ensure zsh completions are accurate:
				set-completion-deno
			HERE
		fi

		export FPATH="$DENO_INSTALL/completions:$FPATH"
	elif [ -n "$BASH_VERSION" ]; then
		alias set-completion-deno="deno completions bash > \"$HOME/.local/share/bash-completion/completions/deno\""

		if [ ! -f "$HOME/.local/share/bash-completion/completions/deno" ]; then
			mkdir -p "$HOME/.local/share/bash-completion/completions"
			deno completions bash > "$HOME/.local/share/bash-completion/completions/deno"

			cat <<-HERE
				# after upgrading deno, run to ensure bash completions are accurate:
				set-completion-deno
			HERE

		fi
	fi

	# not needed since the path is configured already above
	# . "$DENO_INSTALL/env"

fi
