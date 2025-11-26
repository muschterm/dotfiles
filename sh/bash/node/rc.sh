if command -v npm >/dev/null 2>&1; then

	if typeset -f __df-set-completions-npm >/dev/null 2>&1; then
		df-set-completions-npm() {
			__df-set-completions-bash 'npm' 'npm completion'
		}
	fi

fi
