#!/usr/bin/env sh

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

	if [ ! -f "$HOME/.zsh/_deno" ]; then
		mkdir -p "$HOME/.zsh"
		deno completions zsh >"$HOME/.zsh/_deno"
	fi

fi
