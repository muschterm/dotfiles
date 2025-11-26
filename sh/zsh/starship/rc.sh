if command -v starship >/dev/null 2>&1; then
	eval "$(starship init zsh)"

	if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
		df-set-completions-starship() {
			__df-set-completions-zsh 'starship' 'starship completions zsh'
		}
	fi

fi
