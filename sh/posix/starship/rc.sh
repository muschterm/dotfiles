: ${DF_SETUP_STARSHIP:="true"}
if [ "${DF_SETUP_STARSHIP}" = "true" ]; then
	export STARSHIP_HOME="$DF_SOFTWARE_HOME/starship"
	export PATH="$STARSHIP_HOME/bin:$PATH"
	export STARSHIP_CONFIG="$DOTFILES_DIR/sh/posix/starship/starship.toml"

	if ! command -v starship >/dev/null 2>&1; then
		cat <<-HERE
			Installing Starship! into "$STARSHIP_HOME"...
		HERE

		mkdir -p "$STARSHIP_HOME/bin"

		(
			curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$STARSHIP_HOME/bin"
		)
	fi
fi
