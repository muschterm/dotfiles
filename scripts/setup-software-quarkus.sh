: ${DF_SETUP_QUARKUS:="false"}
if [ "${DF_SETUP_QUARKUS}" = "true" ]; then
	# skip if quarkus is not installed
	if ! command -v quarkus >/dev/null; then
		return 0
	fi

	: ${QUARKUS_DOTFILES_DIR:="$DF_SOFTWARE_HOME/quarkus"}

	# completions
	alias set-completions-quarkus="quarkus completion > \"$QUARKUS_DOTFILES_DIR/completions/_quarkus\""
	if [ ! -f "$QUARKUS_DOTFILES_DIR/completions/_quarkus" ]; then
		mkdir -p "$QUARKUS_DOTFILES_DIR/completions"
		quarkus completion > "$QUARKUS_DOTFILES_DIR/completions/_quarkus"

		cat <<-HERE
			# after upgrading Quarkus, run to ensure completions are accurate:
			set-completions-quarkus
		HERE
	fi

	[ -s "$QUARKUS_DOTFILES_DIR/completions/_quarkus" ] && source "$QUARKUS_DOTFILES_DIR/completions/_quarkus"

fi
