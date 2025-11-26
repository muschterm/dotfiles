: ${DF_SETUP_MISE:="true"}
if [ "${DF_SETUP_MISE}" = "true" ]; then
	export MISE_HOME="$DF_SOFTWARE_HOME/mise"
	export PATH="$MISE_HOME/bin:$PATH"
	export MISE_CONFIG_DIR="$DOTFILES_DIR/sh/posix/mise"
	export MISE_CACHE_DIR="$MISE_HOME/cache"
	export MISE_STATE_DIR="$MISE_HOME/state"
	export MISE_DATA_DIR="$MISE_HOME/data"

	if ! command -v mise >/dev/null 2>&1; then
		cat <<-HERE
			Installing Mise! into "$MISE_HOME"...
		HERE

		mkdir -p "$MISE_HOME/bin"

		(
			curl https://mise.run | MISE_INSTALL_PATH="$MISE_HOME/bin/mise" sh
		)
	fi
fi
