if command -v deno >/dev/null 2>&1; then

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-deno() {
			__df-set-completions-bash 'deno' 'deno completions bash'
		}
	fi

fi
