: ${DF_SETUP_QUARKUS:="false"}
if [ "${DF_SETUP_QUARKUS}" = "true" ] && command -v quarkus >/dev/null 2>&1; then

	df_quarkus_completions_dir="$DF_SOFTWARE_HOME/quarkus/completions"

	# match the df-set-completions-<tool> function used by every other tool
	df-set-completions-quarkus() {
		mkdir -p "$df_quarkus_completions_dir" &&
			quarkus completion >"$df_quarkus_completions_dir/_quarkus"
	}

	[ -d "$df_quarkus_completions_dir" ] || mkdir -p "$df_quarkus_completions_dir"

	# `quarkus completion` emits a picocli *bash* script (complete -F ...), so zsh
	# needs bashcompinit before it can be sourced
	if [ -s "$df_quarkus_completions_dir/_quarkus" ]; then
		if [ -n "$ZSH_VERSION" ]; then
			autoload -Uz bashcompinit && bashcompinit
		fi
		. "$df_quarkus_completions_dir/_quarkus"
	fi

fi
