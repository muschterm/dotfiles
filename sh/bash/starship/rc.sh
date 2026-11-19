if command -v starship >/dev/null 2>&1; then
	# omarchy's bash rc already inits starship before ours runs. STARSHIP_CONFIG
	# is read on every prompt, so the one from sh/posix/starship/rc.sh still applies
	if [ "$DF_OMARCHY" != "true" ]; then
		eval "$(starship init bash)"
	fi

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-starship() {
			__df-set-completions-bash 'starship' 'starship completions bash'
		}
	fi
fi
