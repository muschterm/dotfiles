: ${DF_SETUP_QUARKUS:="false"}
if [ "${DF_SETUP_QUARKUS}" = "true" ]; then
	# skip if quarkus is not installed
	if ! command -v quarkus >/dev/null; then
		return 0
	fi

	: ${QUARKUS_DOT_DIR:="$HOME/.quarkus"}

	alias set-completion-quarkus="quarkus completion > \"$QUARKUS_DOT_DIR/_quarkus\""

	if [ ! -d "$QUARKUS_DOT_DIR" ]; then
		cat <<-HERE
			Installing Quarkus Completions into "$QUARKUS_DOT_DIR"...
		HERE

		mkdir -p "$QUARKUS_DOT_DIR"
 
		cat <<-HERE
			# after upgrading Quarkus, run to ensure completions are accurate:
			set-completion-quarkus
		HERE
	fi

	if [ ! -f "$QUARKUS_DOT_DIR/_quarkus" ]; then
		quarkus completion > "$QUARKUS_DOT_DIR/_quarkus"
	fi

	[ -s "$QUARKUS_DOT_DIR/_quarkus" ] && source "$QUARKUS_DOT_DIR/_quarkus"

fi
