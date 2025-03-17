: ${DF_SETUP_SDKMAN:="false"}
if [ "${DF_SETUP_SDKMAN}" = "true" ]; then
	: ${SDKMAN_DIR:="$HOME/.sdkman"}

	if [ ! -d "$SDKMAN_DIR" ]; then
		cat <<-HERE
			Installing SDKMAN! into "$SDKMAN_DIR"...
		HERE

		(
			curl -s "https://get.sdkman.io?rcupdate=false" | bash
		)
	fi

	# SDKMAN! is installed; add to path.
	[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && . "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
