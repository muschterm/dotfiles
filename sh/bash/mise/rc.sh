if command -v mise >/dev/null 2>&1; then
	case $- in
		*i*)
			eval "$(mise activate bash)" 
			;;
		*)
			eval "$(mise activate bash --shims)" 
			;;
	esac

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-mise() {
			__df-set-completions-bash 'mise' 'mise completion bash'
		}
	fi
fi
