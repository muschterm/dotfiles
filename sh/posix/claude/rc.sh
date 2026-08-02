: ${DF_SETUP_CLAUDE:="false"}
if [ "${DF_SETUP_CLAUDE}" = "true" ]; then
	export CLAUDE_HOME="$HOME/.local/bin"
	export CLAUDE_BIN="$HOME/.local/bin/claude"
	export CLAUDE_SHARE="$HOME/.local/share/claude"

	# since claude currently installs to a common .local/bin
	# ensure it's not already on the path
	df-path-prepend "$CLAUDE_HOME"

	if ! command -v claude >/dev/null 2>&1; then
		cat <<-HERE
			Installing Claude! into "$CLAUDE_HOME"...

			bin:   "$CLAUDE_BIN"
			share: "$CLAUDE_SHARE"
		HERE

		(
			curl -fsSL https://claude.ai/install.sh | bash
		)
	fi

	# to uninstall claude:
	# rm -f "$CLAUDE_BIN"
	# rm -rf "$CLAUDE_SHARE"
fi
