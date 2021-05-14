#!/usr/bin/env sh

# reset
export DF_ATTR_RESET_ALL="0"
export DF_ATTR_RESET_BOLD="21"
export DF_ATTR_RESET_DIM="22"
if [ "${TERM:0:5}" = "xterm" ]; then
	# xterm does not reset bold correctly
	export DF_ATTR_RESET_BOLD=$DF_ATTR_RESET_DIM
fi
export DF_ATTR_RESET_ITALICS="23"
export DF_ATTR_RESET_UNDERLINE="24"
export DF_ATTR_RESET_BLINK="25"
export DF_ATTR_RESET_REVERSE="27"
export DF_ATTR_RESET_HIDDEN="28"

# formatting
export DF_FMT_BOLD="1"
export DF_FMT_DIM="2"
export DF_FMT_ITALICS="3" # this only works in certain terminals
export DF_FMT_UNDERLINE="4"
export DF_FMT_BLINK="5"
export DF_FMT_REVERSE="7"
export DF_FMT_HIDDEN="8" # good for passwords

# background color
export DF_BG_DEFAULT="49"
export DF_BG_BLACK="40"
export DF_BG_RED="41"
export DF_BG_GREEN="42"
export DF_BG_YELLOW="43"
export DF_BG_BLUE="44"
export DF_BG_MAGENTA="45"
export DF_BG_CYAN="46"
export DF_BG_LIGHT_GRAY="47"
export DF_BG_DARK_GRAY="100"
export DF_BG_LIGHT_BLUE="104"
export DF_BG_LIGHT_MAGENTA="105"
export DF_BG_LIGHT_CYAN="106"
export DF_BG_WHITE="107"

# foreground color
export DF_FG_DEFAULT="39"
export DF_FG_BLACK="30"
export DF_FG_RED="31"
export DF_FG_GREEN="32"
export DF_FG_YELLOW="33"
export DF_FG_BLUE="34"
export DF_FG_MAGENTA="35"
export DF_FG_CYAN="36"
export DF_FG_LIGHT_GRAY="37"
export DF_FG_DARK_GRAY="90"
export DF_FG_LIGHT_RED="91"
export DF_FG_LIGHT_GREEN="92"
export DF_FG_LIGHT_YELLOW="93"
export DF_FG_LIGHT_BLUE="94"
export DF_FG_LIGHT_MAGENTA="95"
export DF_FG_LIGHT_CYAN="96"
export DF_FG_WHITE="97"

_fmt() (
	string='\033['
	while [ $# -gt 1 ]; do
		string="${string}${1};"
		shift
	done
	printf -- "${string}${1}m"
)

__get_git_branch() (
	if command -v git > /dev/null; then
		git_branch="$(git branch 2>/dev/null | grep '\*' | awk -F ' ' '{print $2}')"
		if [ ! -z "$git_branch" ]; then
			printf -- " ($git_branch"

			git_ahead="$(git rev-list --count --left-only "${git_branch}...origin/${git_branch}" 2>/dev/null)"
			git_behind="$(git rev-list --count --right-only "${git_branch}...origin/${git_branch}" 2>/dev/null)"

			if [ -z $git_ahead ]; then
				git_ahead=0
			fi

			if [ -z $git_behind ]; then
				git_behind=0
			fi

			if [ $git_ahead -gt 0 ] || [ $git_behind -gt 0 ]; then
				printf -- " ["

				if [ $git_ahead -gt 0 ]; then
					printf -- "ahead $git_ahead"
				fi

				if [ $git_behind -gt 0 ]; then
					if [ $git_ahead -gt 0 ]; then
						printf -- ", "
					fi
					
					printf -- "behind $git_behind"
				fi

				printf -- "]"
			fi

			printf -- ")"
		fi
	fi
)

###############################################################################
# PS1                                                                         #
###############################################################################
local_ps1_prefix="$(_fmt $DF_ATTR_RESET_ALL)"

if [ ! -z $DOCKER_IMAGE_NAME ]; then
	local_ps1_prefix="$(_fmt $DF_FMT_BOLD $DF_FG_YELLOW)["$'\xf0\x9f\x90\xb3'" ${DOCKER_IMAGE_NAME}]$(_fmt $DF_ATTR_RESET_ALL) "
fi

if [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
	setopt PROMPT_SUBST
fi

if [ "$(id -u)" = "0" ]; then
	if [ -n "$BASH_VERSION" ]; then
		PS1="${local_ps1_prefix}$(_fmt $DF_FMT_BOLD $DF_FG_RED)\u $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)\w$(_fmt $DF_FMT_BOLD $DF_FG_YELLOW)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)\n# "
	elif [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
		PS1="${local_ps1_prefix}$(_fmt $DF_FMT_BOLD $DF_FG_RED)%n $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)%~$(_fmt $DF_FMT_BOLD $DF_FG_YELLOW)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)"$'\n# '
	fi
else
	if [ -n "$BASH_VERSION" ]; then
		PS1="${local_ps1_prefix}$(_fmt $DF_FMT_BOLD $DF_FG_GREEN)\u $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)\w$(_fmt $DF_FMT_BOLD $DF_FG_YELLOW)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)\n\$ "
	elif [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
		PS1="${local_ps1_prefix}$(_fmt $DF_FMT_BOLD $DF_FG_GREEN)%n $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)%~$(_fmt $DF_FMT_BOLD $DF_FG_YELLOW)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)"$'\n$ '
	fi
fi

unset local_ps1_prefix
