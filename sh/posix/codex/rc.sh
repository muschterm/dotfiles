: ${DF_SETUP_CODEX:="false"}
if [ "${DF_SETUP_CODEX}" = "true" ]; then
	# codex splits its install in two:
	#   CODEX_INSTALL_DIR - the dir on PATH; holds only a symlink (the entry point)
	#   CODEX_HOME        - config, auth, and the versioned binaries themselves under
	#                       packages/standalone/releases, with 'current' selecting one
	#
	# upstream defaults CODEX_INSTALL_DIR to ~/.local/bin, but omarchy keeps its own
	# npx shim there (see omarchy install/packaging/npx.sh) and would clobber ours on
	# any re-run. install into the dotfiles tree instead so both can coexist, and let
	# PATH order pick the winner.
	#
	# CODEX_HOME stays at the upstream default so config and auth are shared no matter
	# which codex ends up running.
	export CODEX_INSTALL_DIR="$DF_SOFTWARE_HOME/codex/bin"
	export CODEX_BIN="$CODEX_INSTALL_DIR/codex"
	export CODEX_HOME="$HOME/.codex"

	# ~/.local/bin first so ours lands in front of it, whichever rc file gets there
	# first - claude's rc prepends the same dir after this one is sourced
	df-path-prepend "$HOME/.local/bin"
	df-path-prepend "$CODEX_INSTALL_DIR"

	# a codex on PATH may just be omarchy's shim, so look for ours specifically
	if [ ! -x "$CODEX_BIN" ]; then
		cat <<-HERE
			Installing Codex! into "$CODEX_INSTALL_DIR"...

			bin:  "$CODEX_BIN"
			home: "$CODEX_HOME"
		HERE

		(
			# the installer only rewrites a shell profile when its bin dir is
			# missing from PATH - df-path-prepend above keeps that from happening;
			# non-interactive keeps it from prompting during shell startup
			export CODEX_NON_INTERACTIVE="true"
			curl -fsSL https://chatgpt.com/codex/install.sh | sh
		)
	fi

	# to uninstall codex:
	# rm -rf "$DF_SOFTWARE_HOME/codex"
	# rm -rf "$CODEX_HOME/packages"
fi
