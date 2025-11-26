: ${DF_SETUP_QUARKUS:="false"}
if [ "${DF_SETUP_QUARKUS}" = "true" ] && command -v quarkus >/dev/null 2>&1; then

	alias df-set-completions-quarkus="quarkus completion > \"$DF_SOFTWARE_HOME/quarkus/completions/_quarkus\""
	if [ ! -d "$DF_SOFTWARE_HOME/quarkus/completions/_quarkus" ]; then
		mkdir -p "$DF_SOFTWARE_HOME/quarkus/completions"
	else
		[ -s "$DF_SOFTWARE_HOME/quarkus/completions/_quarkus" ] && source "$DF_SOFTWARE_HOME/quarkus/completions/_quarkus"
	fi

fi
