if command -v mise >/dev/null 2>&1; then
	# omarchy's bash rc already activates mise before ours runs (zsh gets nothing
	# from omarchy, so sh/zsh/mise/rc.sh still has to)
	if [ "$DF_OMARCHY" != "true" ]; then
		case $- in
			*i*)
				eval "$(mise activate bash)"
				;;
			*)
				eval "$(mise activate bash --shims)"
				;;
		esac
	fi

	if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
		df-set-completions-mise() {
			__df-set-completions-bash 'mise' 'mise completion bash'
		}
	fi
fi
