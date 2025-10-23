: ${DF_SETUP_CODEX:="false"}
if [ "${DF_SETUP_CODEX}" = "true" ]; then
	# skip if codex is not installed
	if ! command -v codex >/dev/null; then
		return 0
	fi

	: ${CODEX_DOTFILES_DIR:="$DF_SOFTWARE_HOME/codex"}

	# completions
	alias set-completions-codex="codex completion zsh > \"$CODEX_DOTFILES_DIR/completions/_codex\""
	if [ ! -f "$CODEX_DOTFILES_DIR/completions/_codex" ]; then
		mkdir -p "$CODEX_DOTFILES_DIR/completions"
		codex completion zsh > "$CODEX_DOTFILES_DIR/completions/_codex"

		cat <<-HERE
			# after upgrading Codex, run to ensure completions are accurate:
			set-completions-codex
		HERE
	fi

	[ -s "$CODEX_DOTFILES_DIR/completions/_codex" ] && source "$CODEX_DOTFILES_DIR/completions/_codex"
fi
