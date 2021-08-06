#!/usr/bin/env sh

__get_git_branch() (
	if command -v git > /dev/null; then
		git_branch="$(git branch 2>/dev/null | grep '\*' | awk -F ' ' '{print $2}')"
		if [ ! -z "$git_branch" ]; then
			printf -- "\uE725 $git_branch"

			git_ahead="$(git rev-list --count --left-only "${git_branch}...origin/${git_branch}" 2>/dev/null)"
			git_behind="$(git rev-list --count --right-only "${git_branch}...origin/${git_branch}" 2>/dev/null)"

			if [ -z $git_ahead ]; then
				git_ahead=0
			fi

			if [ -z $git_behind ]; then
				git_behind=0
			fi

			if [ $git_ahead -gt 0 ] || [ $git_behind -gt 0 ]; then
				printf -- " "

				if [ $git_ahead -gt 0 ]; then
					# printf -- "\U0001F811$git_ahead"
					printf -- "\u21E1$git_ahead"
					# printf -- "\u2191$git_ahead"
				fi

				if [ $git_behind -gt 0 ]; then
					if [ $git_ahead -gt 0 ]; then
						printf -- ", "
					fi
					
					printf -- "\u21E3$git_behind"
					# printf -- "\u2193$git_behind"
					# printf -- "\U0001F813$git_behind"
				fi
			fi
		fi
	fi
)

__get_distro() (
	local_ps1_prefix=
	if [ "$DF_OS_LINUX" = "true" ]; then
		distro="$(print-distro)"
		if [ "$distro" = "ubuntu" ]; then
			local_ps1_prefix="\uF31B"
		elif [ "$distro" = "alpine" ]; then
			local_ps1_prefix="\uF300"
		else 
			local_ps1_prefix="\uF17C"
		fi
	elif [ "$DF_OS_MACOS" = "true" ]; then
		local_ps1_prefix="\uF302"	
	fi

	if [ "$(cat /proc/1/cgroup 2>/dev/null | grep "/docker/" | wc -l)" != "0" ]; then
		local_ps1_prefix="$local_ps1_prefix\uF45C\uF308"
	fi

	printf -- "$(_fmt $DF_ATTR_RESET_ALL)$local_ps1_prefix"
)


###############################################################################
# PS1                                                                         #
###############################################################################


if [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
	setopt PROMPT_SUBST
fi

if [ "$(id -u)" = "0" ]; then
	if [ -n "$BASH_VERSION" ]; then
		PS1=$'\n'"\$(__get_distro) "$'\uE621'" $(_fmt $DF_FMT_BOLD $DF_FG_RED)\u$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)\w$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)\n# "
	elif [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
		PS1=$'\n'"\$(__get_distro) "$'\uE621'" $(_fmt $DF_FMT_BOLD $DF_FG_RED)%n$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)%~$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)"$'\n# '
	fi
else
	if [ -n "$BASH_VERSION" ]; then
		PS1=$'\n'"\$(__get_distro) "$'\uE621'" $(_fmt $DF_FMT_BOLD)\u$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)\w$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)\n\$ "
	elif [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
		PS1=$'\n'"\$(__get_distro) "$'\uE621'" $(_fmt $DF_FMT_BOLD)%n$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)%~$(_fmt $DF_ATTR_RESET_ALL) "$'\uE621'" $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)"$'\n\uF66B '
	fi
fi

unset local_ps1_prefix
