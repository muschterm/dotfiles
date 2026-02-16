if command -v mise >/dev/null 2>&1; then
	case $- in
		*i*)
			eval "$(mise activate zsh)" 
			;;
		*)
			eval "$(mise activate zsh --shims)" 
			;;
	esac

	if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
		df-set-completions-mise() {
			__df-set-completions-zsh 'mise' 'mise completion zsh'
		}
	fi

fi
