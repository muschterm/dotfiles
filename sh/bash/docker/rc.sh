if command -v docker >/dev/null 2>&1; then

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-docker() {
			__df-set-completions-bash 'docker' 'docker completion bash'
		}
	fi

fi
