if command -v starship >/dev/null 2>&1; then
	eval "$(starship init bash)"

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-starship() {
			__df-set-completions-bash 'starship' 'starship completions bash'
		}
	fi
fi
