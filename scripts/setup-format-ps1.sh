# Nerd Font ICONs used
# ---

nf_indent_line=$'\xee\x98\xa1'
#  | nf-indent-line | UTF \ue621 | \xee\x98\xa1
#   hexdump
#     0000000 98ee 00a1
#     0000003

nf_oct_git_branch=$'\xef\x90\x98'
#  | nf-oct-git_branch | UTF \uf418 | \xef\x90\x98
#   hexdump
#     0000000 90ef 0098
#     0000003

nf_dev_git_branch=$'\xee\x9c\xa5'
#  | nf-dev-git_branch | UTF \ue725 | \xee\x9c\xa5
#   hexdump
#     0000000 9cee 00a5
#     0000003

upwards_dashed_arrow=$'\xe2\x87\xa1'
# ⇡ | [not nerd font - git ahead] upwards_dashed_arrow | UTF \u21e1 | \xe2\x87\xa1
#   hexdump
#     0000000 87e2 00a1
#     0000003

downwards_dashed_arrow=$'\xe2\x87\xa3'
# ⇣ | [not nerd font - git behind] downwards_dashed_arrow | UTF \u21e3 | \xe2\x87\xa3
#   hexdump
#     0000000 87e2 00a3
#     0000003
# ---

nf_linux_debian=$'\xef\x8c\x86'
#  | nf-linux-debian | UTF \uf306 | \xef\x8c\x86
#   hexdump
#     0000000 8cef 0086
#     0000003

nf_linux_ubuntu=$'\xef\x8c\x9b'
#  | nf-linux-ubuntu | UTF \uf31b | \xef\x8c\x9b
#   hexdump
#     0000000 8cef 009b
#     0000003

nf_linux_pop=$'\xef\x8c\xaa'
#  | nf-linux-pop_os | UTF \uf32a | \xef\x8c\xaa
#   hexdump
#     0000000 8cef 00aa
#     0000003

nf_linux_tux=$'\xef\x8c\x9a'
#  | nf-linux-tux | UTF \uf31a | \xef\x8c\x9a
#   hexdump
#     0000000 8cef 009a
#     0000003

nf_linux_apple=$'\xef\x8c\x82'
#  | nf-linux-apple | UTF \uf302 | \xef\x8c\x82
#   hexdump
#     0000000 8cef 0082
#     0000003

nf_md_microsoft_windows=$'\xf3\xb0\x96\xb3'
# 󰖳 | nf-md-microsoft_windows | UTF \udb81\uddb3 | \xf3\xb0\x96\xb3
#   hexdump
#     0000000 b0f3 b396
#     0000004

nf_oct_chevron_right=$'\xef\x91\xa0'
#  | nf-oct-chevron_right | UTF \uf460 | \xef\x91\xa0
#   hexdump
#     0000000 91ef 00a0
#     0000003

nf_md_docker=$'\xf3\xb0\xa1\xa8'
# 󰡨 | nf-md-docker | UTF \udb82\udc68 | \xf3\xb0\xa1\xa8
#   hexdump
#     0000000 b0f3 a8a1
#     0000004

nf_md_code_greater_than=$'\xf3\xb0\x85\xac'
# 󰅬 | nf-md-code_greater_than | UTF \udb80\udd6c | \xf3\xb0\x85\xac
#   hexdump
#     0000000 b0f3 ac85
#     0000004

__get_git_branch() (
	if command -v git >/dev/null; then
		git_branch="$(git branch 2>/dev/null | grep '\*' | awk -F ' ' '{print $2}')"
		if [ ! -z "$git_branch" ]; then
			printf -- "$nf_oct_git_branch $git_branch"

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
					printf -- "$upwards_dashed_arrow$git_ahead"
					# printf -- "\u2191$git_ahead"
				fi

				if [ $git_behind -gt 0 ]; then
					printf -- "$downwards_dashed_arrow$git_behind"
					# printf -- "\u2193$git_behind"
					# printf -- "\U0001F813$git_behind"
				fi
			fi
		fi
	fi
)

__get_distro() (
	local_ps1_prefix=
	if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
		distro="$(print-distro)"
		case "$distro" in
		"debian")
			local_ps1_prefix="$nf_linux_debian"
			;;
		"ubuntu")
			local_ps1_prefix="$nf_linux_ubuntu"
			;;
		"pop")
			local_ps1_prefix="$nf_linux_pop"
			;;
		"raspbian")
			local_ps1_prefix="\uF315"
			;;
		"alpine")
			local_ps1_prefix="\uF300"
			;;
		"arch")
			local_ps1_prefix="\uF303"
			;;
		"fedora")
			local_ps1_prefix="\uF30A"
			;;
		"centos")
			local_ps1_prefix="\uF304"
			;;
		"rhel")
			local_ps1_prefix="\uF316"
			;;
		*)
			# penguin
			local_ps1_prefix="$nf_linux_tux"
			;;
		esac
	elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		local_ps1_prefix="$nf_linux_apple"
	elif [ "$DF_OS" = "$DF_OS_WINDOWS" ]; then
		local_ps1_prefix="$nf_md_microsoft_windows"
	fi

	if [ "$(cat /proc/1/cgroup 2>/dev/null | grep "/docker/" | wc -l | tr -d "[:space:]")" != "0" ] || [ -f "/.dockerenv" ]; then
		# [distro] -> [docker logo]
		local_ps1_prefix="$local_ps1_prefix$nf_oct_chevron_right$nf_md_docker"
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
		PS1=$'\n'"\$(__get_distro) $nf_indent_line $(_fmt $DF_FMT_BOLD $DF_FG_RED)\u$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)\w$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)\n# "
	elif [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
		PS1=$'\n'"\$(__get_distro) $nf_indent_line $(_fmt $DF_FMT_BOLD $DF_FG_RED)%n$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)%~$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)"$'\n# '
	fi
else
	if [ -n "$BASH_VERSION" ]; then
		PS1=$'\n'"\$(__get_distro) $nf_indent_line $(_fmt $DF_FMT_BOLD)\u$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)\w$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)\n\$ "
	elif [ -n "$ZSH_VERSION" ] && [ -z "$ZSH" ]; then
		PS1=$'\n'"\$(__get_distro) $nf_indent_line $(_fmt $DF_FMT_BOLD)%n$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FMT_BOLD $DF_FG_BLUE)%~$(_fmt $DF_ATTR_RESET_ALL) $nf_indent_line $(_fmt $DF_FG_GREEN)\$(__get_git_branch)$(_fmt $DF_ATTR_RESET_ALL)"$'\n'"$nf_md_code_greater_than "
	fi
fi

unset local_ps1_prefix
