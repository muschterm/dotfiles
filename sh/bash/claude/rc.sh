if command -v claude >/dev/null 2>&1; then

	# `claude completion bash` is not yet supported upstream; the ':' keeps the
	# if-body non-empty, which bash requires (zsh tolerates an empty one).
	:

	# if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
	# 	df-set-completions-claude() {
	# 		__df-set-completions-bash 'claude' 'claude completion bash'
	# 	}
	# fi

fi
