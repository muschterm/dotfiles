read_timeout() {
	(
		trap : USR1
		trap 'kill "$pid" 2> /dev/null' EXIT
		(sleep "$1" && kill -USR1 "$$") &
		pid=$!
		read -r "$2"
		ret=$?
		kill "$pid" 2>/dev/null
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
	while [ -z "${1%%-*}" ]; do # while [ "${1:0:1}" = "-" ] || [ "${1:0:2}" = "--" ]
		new_attr_var=
		new_reset_attr_var=
		case $1 in
		"--red")
			new_attr_var="$DF_FG_RED"
			reset_color=true
			shift
			;;
		"--green")
			new_attr_var="$DF_FG_GREEN"
			reset_color=true
			shift
			;;
		"--yellow")
			new_attr_var="$DF_FG_YELLOW"
			reset_color=true
			shift
			;;
		"--blue")
			new_attr_var="$DF_FG_BLUE"
			reset_color=true
			shift
			;;
		"--light-gray")
			new_attr_var="$DF_FG_LIGHT_GRAY"
			reset_color=true
			shift
			;;
		"--dark-gray")
			new_attr_var="$DF_FG_DARK_GRAY"
			reset_color=true
			shift
			;;
		"-n")
			newline=
			shift
			;;
		"-b" | "--bold")
			new_attr_var="$DF_FMT_BOLD"
			new_reset_attr_var="$DF_ATTR_RESET_BOLD"
			shift
			;;
		"-d" | "--dim")
			new_attr_var="$DF_FMT_DIM"
			new_reset_attr_var="$DF_ATTR_RESET_DIM"
			shift
			;;
		"-u" | "--underline")
			new_attr_var="$DF_FMT_UNDERLINE"
			new_reset_attr_var="$DF_ATTR_RESET_UNDERLINE"
			shift
			;;
		"-m" | "--markdown")
			shift
			use_markdown=true
			;;
		"-h" | "--help")
			cat <<-HERE
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
		"--")
			shift
			break
			;;
		*)
			break
			;;
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
			temptext="$(timeout 1 cat 2>/dev/null)"

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

run_command() {
	printf -- "$(_fmt $DF_FMT_DIM)"
	eval $@
	printf -- "$(_fmt $DF_ATTR_RESET_DIM)"
}
