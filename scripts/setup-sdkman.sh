#!/usr/bin/env sh

: ${DF_SETUP_SDKMAN:="false"}
if [ "${DF_SETUP_SDKMAN}" = "true" ]; then
	: ${DF_SDKMAN_DIR:="$HOME/.sdkman"}
	
	if [ ! -d "$DF_SDKMAN_DIR" ]; then
		cat <<- HERE
		Installing SDKMAN! into "$DF_SDKMAN_DIR"...
		HERE

		(
			curl -s "https://get.sdkman.io?rcupdate=false" | bash
		)
	fi

	# SDKMAN! is installed; add to path.
	[ -s "$DF_SDKMAN_DIR/bin/sdkman-init.sh" ] && . "$DF_SDKMAN_DIR/bin/sdkman-init.sh"
fi
