: ${DF_SETUP_MISE:="true"}
if [ "${DF_SETUP_MISE}" = "true" ]; then
	if [ "$DF_OMARCHY" = "true" ]; then
		# omarchy ships mise as a package and wires it up itself - default data dir
		# (shims, command-wrappers) and activation in its bash rc. overriding the
		# dirs here would split tools between two installs, so only bring the config
		mise_config_file="${XDG_CONFIG_HOME:-$HOME/.config}/mise/config.toml"
		mise_dotfiles_config_file="$DOTFILES_DIR/sh/posix/mise/config.toml"

		# readlink isn't POSIX - pull the target off the end of `ls -l` instead
		mise_config_target=
		if [ -L "$mise_config_file" ]; then
			mise_config_target="$(ls -l "$mise_config_file")"
			mise_config_target="${mise_config_target#* -> }"
		fi

		if [ "$mise_config_target" != "$mise_dotfiles_config_file" ]; then
			mkdir -p "$(dirname "$mise_config_file")"

			# keep whatever omarchy (or the user) put there rather than clobbering it
			if [ -e "$mise_config_file" ] || [ -L "$mise_config_file" ]; then
				mv "$mise_config_file" "$mise_config_file.bak"
				cat <<-HERE
					Moved existing mise config to "$mise_config_file.bak"
				HERE
			fi

			ln -s "$mise_dotfiles_config_file" "$mise_config_file"
		fi

		unset mise_config_file mise_dotfiles_config_file mise_config_target
	else
		export MISE_HOME="$DF_SOFTWARE_HOME/mise"
		df-path-prepend "$MISE_HOME/bin"
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
fi
