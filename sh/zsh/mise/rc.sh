if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate zsh)"

	if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
		df-set-completions-mise() {
			__df-set-completions-zsh 'mise' 'mise completion zsh'
		}
	fi

fi
