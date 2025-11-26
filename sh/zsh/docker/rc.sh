if command -v docker >/dev/null 2>&1; then

	if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
		df-set-completions-docker() {
			__df-set-completions-zsh 'docker' 'docker completion zsh'
		}
	fi

fi
