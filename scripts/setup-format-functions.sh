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

read_timeout() {
	(
		trap : USR1
		trap 'kill "$pid" 2> /dev/null' EXIT
		(sleep "$1" && kill -USR1 "$$") & pid=$!
		read -r "$2"
		ret=$?
		kill "$pid" 2> /dev/null
		trap - EXIT
		return "$ret"
	)
}

newline() {
	printf -- '\n'
}

text() {
	newline="\n"
	attr_var=
	reset_attr_var=
	reset_color=false
	use_markdown=false
	help_only=false
	while [ -z "${1%%-*}" ]
	# while [ "${1:0:1}" = "-" ] || [ "${1:0:2}" = "--" ]
	do
		new_attr_var=
		new_reset_attr_var=
		case $1 in
			"--red" )
				new_attr_var="$DF_FG_RED"
				reset_color=true
				shift
				;;
			"--green" )
				new_attr_var="$DF_FG_GREEN"
				reset_color=true
				shift
				;;
			"--yellow" )
				new_attr_var="$DF_FG_YELLOW"
				reset_color=true
				shift
				;;
			"--blue" )
				new_attr_var="$DF_FG_BLUE"
				reset_color=true
				shift
				;;
			"--light-gray" )
				new_attr_var="$DF_FG_LIGHT_GRAY"
				reset_color=true
				shift
				;;
			"--dark-gray" )
				new_attr_var="$DF_FG_DARK_GRAY"
				reset_color=true
				shift
				;;
			"-n" )
				newline=
				shift
				;;
			"-b" | "--bold" )
				new_attr_var="$DF_FMT_BOLD"
				new_reset_attr_var="$DF_ATTR_RESET_BOLD"
				shift
				;;
			"-d" | "--dim" )
				new_attr_var="$DF_FMT_DIM"
				new_reset_attr_var="$DF_ATTR_RESET_DIM"
				shift
				;;
			"-u" | "--underline" )
				new_attr_var="$DF_FMT_UNDERLINE"
				new_reset_attr_var="$DF_ATTR_RESET_UNDERLINE"
				shift
				;;
			"-m" | "--markdown" )
				shift
				use_markdown=true
				;;
			"-h" | "--help" )
				cat <<- HERE
				Helper script that is to be sourced into other script files for helper functions.

				  Usage:
				    text [OPTIONS]

				    Once sourced into another script file, the following functions are available to use:

				      $(_fmt $DF_FMT_BOLD)text$(_fmt $DF_ATTR_RESET_BOLD)
				                          Instead of using printf or echo.

				            --red
				            --green
				            --yellow
				            --blue
				            --light-gray
				            --dark-gray
				        -n                Do not use a newline character at end
				        -b, --bold
				        -d, --dim
				        -u, --underline
				        -m, --markdown    Markdown mode - supports all options, but using markdown/html syntax.

				      $(_fmt $DF_FMT_BOLD)success$(_fmt $DF_ATTR_RESET_BOLD)
				                          Helps print text that represents a successful action occurred.

				      $(_fmt $DF_FMT_BOLD)warn$(_fmt $DF_ATTR_RESET_BOLD)
				                          Helps print text that represents a warning.

				      $(_fmt $DF_FMT_BOLD)fail$(_fmt $DF_ATTR_RESET_BOLD)
				                          Helps print text that represents a failure.

				      $(_fmt $DF_FMT_BOLD)run_command$(_fmt $DF_ATTR_RESET_BOLD)
				                          Wraps a command to execute ensuring the output is deemphasized from the
				                          the rest of the output.

				    Options:
				      --trap-errors       Default false. Flag that determines whether or not trapping errors is 
				                          turned on. *This is useful for handling step by step scripts that should*
				                          *fail completely if a single step fails.*

				      -h, --help

				    Examples:
				      $ text "Hello, World!"
				      Hello, World!

				      $ success "It worked!"
				      $(_fmt $DF_FG_GREEN)It worked!$(_fmt $DF_FG_DEFAULT)

				      $ text -m "Hello, **World**! It <green>worked</green>!"
				      Hello, $(_fmt $DF_FMT_BOLD)World$(_fmt $DF_ATTR_RESET_BOLD)! It $(_fmt $DF_FG_GREEN)worked$(_fmt $DF_FG_DEFAULT)!
				HERE
				help_only=true
				break
				;;
			"--" )
				shift
				break
				;;
			*)
				break
		esac

		if [ "$new_attr_var" != "" ]; then
			if [ "$attr_var" != "" ]; then
				attr_var="$attr_var $new_attr_var"
			else
				attr_var="$new_attr_var"
			fi
		fi

		if [ "$new_reset_attr_var" != "" ]; then
			if [ "$reset_attr_var" != "" ]; then
				reset_attr_var="$reset_attr_var $new_reset_attr_var"
			else
				reset_attr_var="$new_reset_attr_var"
			fi
		fi
	done

	if [ "$help_only" = "false" ]; then
		printf -- "$(_fmt $(printf -- "$attr_var"))"

		temptext=$1
		if [ -z "$temptext" ]; then
			# This is necessary - some POSIX shells do not support auto timing out
			# on cat if the input just hangs. This ensures when called without data 
			# that this will never wait forever.
			temptext="$(timeout 1 cat 2> /dev/null)"

			# The below only works in BASH
			# # if [ ! -z "$(read --help 2> /dev/null | grep "\-t timeout")" ]; then
			# 	while IFS= read -r -t 1 line
			# 	# while IFS= read_timeout 1 line
			# 	do
			# 		temptext="$line\n$(cat)"
			# 	done < /dev/stdin
			# # fi
		fi

		if [ "$use_markdown" = "true" ]; then
			# handle markdown bold, italics, and underline
			temptext=$(printf -- "$temptext" | sed "s/\(\S\)\*\*/\\1\\\033[${reset_bold}m/g;s/\*\*\(\S\)/\\\033[1m\\1/g")
			temptext=$(printf -- "$temptext" | sed "s/\(\S\)\*/\\1\\\033\[23m/g;s/\*\(\S\)/\\\033\[3m\\1/g")
			temptext=$(printf -- "$temptext" | sed "s/<u>/\\\033\[4m/g;s/<\/u>/\\\033\[24m/g")
			temptext=$(printf -- "$temptext" | sed "s/<red>/\\\033\[31m/g;s/<\/red>/\\\033\[39m/g")
			temptext=$(printf -- "$temptext" | sed "s/<green>/\\\033\[32m/g;s/<\/green>/\\\033\[39m/g")
			temptext=$(printf -- "$temptext" | sed "s/<yellow>/\\\033\[33m/g;s/<\/yellow>/\\\033\[39m/g")
			temptext=$(printf -- "$temptext" | sed "s/<blue>/\\\033\[34m/g;s/<\/blue>/\\\033\[39m/g")
			temptext=$(printf -- "$temptext" | sed "s/<light-gray>/\\\033\[37m/g;s/<\/light-gray>/\\\033\[39m/g")
			temptext=$(printf -- "$temptext" | sed "s/<dark-gray>/\\\033\[90m/g;s/<\/dark-gray>/\\\033\[39m/g")
		fi

		printf -- "$temptext"
		if [ "$reset_color" = "true" ]; then
			printf -- "$(_fmt $DF_FG_DEFAULT)"
		fi

		if [ "$reset_attr_var" != "" ]; then
			printf -- "$(_fmt $(printf -- "$reset_attr_var"))"
		fi

		if [ "$newline" != "" ]; then
			printf -- "$newline"
		fi
	fi
}

success() {
	text -b --green "$1"
}

warn() {
	text -b --yellow "$1"
}

fail() {
	text -b --red "$1"
}

run-command() {
	printf -- "$(_fmt $DF_FMT_DIM)"
	eval $@
	printf -- "$(_fmt $DF_ATTR_RESET_DIM)"
}
