if command -v claude >/dev/null 2>&1; then

	# `claude completion zsh` is not yet supported upstream; the ':' keeps the
	# if-body non-empty, which bash requires (zsh tolerates an empty one).
	:

	# if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
	# 	df-set-completions-claude() {
	# 		__df-set-completions-zsh 'claude' 'claude completion zsh'
	# 	}
	# fi

fi
