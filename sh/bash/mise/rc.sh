if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate bash)"

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-mise() {
			__df-set-completions-bash 'mise' 'mise completion bash'
		}
	fi
fi
