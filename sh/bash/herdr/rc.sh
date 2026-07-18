if command -v herdr >/dev/null 2>&1; then

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-herdr() {
			__df-set-completions-bash 'herdr' 'herdr completion bash'
		}
	fi

fi
