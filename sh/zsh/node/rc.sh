if command -v npm >/dev/null 2>&1; then

	if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
		df-set-completions-npm() {
			__df-set-completions-zsh 'npm' 'npm completion'
		}
	fi

fi
