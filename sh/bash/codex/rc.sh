if command -v codex >/dev/null 2>&1; then

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-codex() {
			__df-set-completions-bash 'codex' 'codex completion bash'
		}
	fi

fi
