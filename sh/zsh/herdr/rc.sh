if command -v herdr >/dev/null 2>&1; then

	if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
		df-set-completions-herdr() {
			__df-set-completions-zsh 'herdr' 'herdr completion zsh'
		}
	fi

fi
