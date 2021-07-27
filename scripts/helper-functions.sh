#!/usr/bin/env sh

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
		case $1 in
			"--red" )
				attr_var="$attr_var $DF_FG_RED"
				reset_color=true
				shift
				;;
			"--green" )
				attr_var="$attr_var $DF_FG_GREEN"
				reset_color=true
				shift
				;;
			"--yellow" )
				attr_var="$attr_var $DF_FG_YELLOW"
				reset_color=true
				shift
				;;
			"--blue" )
				attr_var="$attr_var $DF_FG_BLUE"
				reset_color=true
				shift
				;;
			"--light-gray" )
				attr_var="$attr_var $DF_FG_LIGHT_GRAY"
				reset_color=true
				shift
				;;
			"--dark-gray" )
				attr_var="$attr_var $DF_FG_DARK_GRAY"
				reset_color=true
				shift
				;;
			"-n" )
				newline=
				shift
				;;
			"-b" | "--bold" )
				attr_var="$attr_var $DF_FMT_BOLD"
				reset_attr_var="$reset_attr_var $DF_ATTR_RESET_BOLD"
				shift
				;;
			"-d" | "--dim" )
				attr_var="$attr_var $DF_FMT_DIM"
				reset_attr_var="$reset_attr_var $DF_ATTR_RESET_DIM"
				shift
				;;
			"-u" | "--underline" )
				attr_var="$attr_var $DF_FMT_UNDERLINE"
				reset_attr_var="$reset_attr_var $DF_ATTR_RESET_UNDERLINE"
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
	done

	if [ "$help_only" = "false" ]; then
		printf -- "$(_fmt $attr_var)"

		temptext=$1
		if [ -z "$temptext" ]; then
			# This is necessary - some POSIX shells do not support auto timing out
			# on cat if the input just hangs. This ensure that anything called without
			# data that this will never wait forever.
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

		printf -- "$(_fmt $reset_attr_var)$newline"
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

call_http() {
	(
		scheme_option_1="http"
		scheme_option_2="https"

		host_option_1="localhost"
		host_option_2="127.0.0.1"
		host_option_3="$(ifconfig -a | grep "inet " | grep -v "127" | awk '{print $2}')"
		host_option_4="$(curl -s ifconfig.me)"

		port_option_1="8080"
		port_option_2="8443"

		method_option_1="GET"
		method_option_2="POST"
		method_option_3="PUT"
		method_option_4="PATCH"
		method_option_5="DELETE"
		method_option_6="HEAD"
		method_option_7="OPTION"

		content_type_option_1="application/json"
		content_type_option_2="application/xml"
		content_type_option_3="application/www-x-form-urlencoded"

		scheme=
		host=
		port=
		method=

		curl_options=

		newline
		text -m "**Select SCHEME:** [1, 2, etc.]"
		text -m "  1) $scheme_option_1"
		text -m "  2) $scheme_option_2"
		text -m "  3) [custom]"
		text -n -m "**SCHEME:** "
		read scheme_option
		if [ $scheme_option -gt 0 ] && [ $scheme_option -lt 3 ]; then
			eval temp_scheme=\"\$scheme_option_$scheme_option\"
			scheme="$temp_scheme"
		elif [ $scheme_option = 3 ]; then
			text -n -m "**Custom Scheme:** "
			read scheme
		else
			fail "invalid option"
			exit 1
		fi

		newline
		text -m "**Select HOST:** [1, 2, etc.]"
		text -m "  1) $host_option_1"
		text -m "  2) $host_option_2"
		text -m "  3) $host_option_3 (private IP)"
		text -m "  4) $host_option_4 (public  IP)"
		text -m "  5) [custom]"
		text -n -m "**HOST:** "
		read host_option
		if [ $host_option -gt 0 ] && [ $host_option -lt 5 ]; then
			eval temp_host=\"\$host_option_$host_option\"
			host="$temp_host"
		elif [ $host_option = 5 ]; then
			text -n -m "**Custom Host:** "
			read host
		else
			fail "invalid option"
			exit 1
		fi

		if [ "$host" = "$host_option_1" ] || [ "$host" = "$host_option_2" ]; then
			curl_options="--noproxy \"*\""
		fi

		newline
		text -m "**Select PORT:** [1, 2, etc.]"
		text -m "  1) $port_option_1"
		text -m "  2) $port_option_2"
		text -m "  3) No Port"
		text -m "  4) [custom]"
		text -n -m "**PORT:** "
		read port_option
		if [ $port_option -gt 0 ] && [ $port_option -lt 4 ]; then
			eval temp_port=\"\$port_option_$port_option\"
			port="$temp_port"
		elif [ $port_option = 4 ]; then
			text -n -m "**Custom Port:** "
			read port
		else
			fail "invalid option"
			exit 1
		fi

		if [ ! -z "$port" ]; then
			port=":$port"
		fi

		newline
		text -m "**Select METHOD:** [1, 2, etc.]"
		text -m "  1) $method_option_1"
		text -m "  2) $method_option_2"
		text -m "  3) $method_option_3"
		text -m "  4) $method_option_4"
		text -m "  5) $method_option_5"
		text -m "  6) $method_option_6"
		text -m "  7) $method_option_7"
		text -n -m "**METHOD:** "
		read method_option
		if [ $method_option -gt 0 ] && [ $method_option -lt 8 ]; then
			eval temp_method=\"\$method_option_$method_option\"
			method="$temp_method"
		else
			fail "invalid option"
			exit 1
		fi

		newline
		text -n -m "**Enter PATH:** "
		read path

		curl_command="curl $curl_options -si"

		if [ "$method" = "POST" ] || [ "$method" = "PUT" ] || [ "$method" = "PATCH" ]; then
			text -m "**Select Content-Type:** [1, 2, etc.]"
			text -m "  1) $content_type_option_1"
			text -m "  2) $content_type_option_2"
			text -m "  3) $content_type_option_3"
			text -m "  4) [custom]"
			text -n -m "**Content-Type:** "
			read content_type_option
			if [ $content_type_option -gt 0 ] && [ $content_type_option -lt 4 ]; then
				eval temp_content_type=\"\$content_type_option_$content_type_option\"
				content_type="$temp_content_type"
			elif [ $content_type_option = 4 ]; then
				text -n -m "**Custom Content-Type:** "
				read content_type
			else
				fail "invalid option"
				exit 1
			fi

			newline
			text -n -m "**Request Payload (CTRL + D To Complete):** "
			
			d="$(</dev/stdin)"
			if [ ! -z "$(printf -- "$content_type" | grep "json")" ]; then
				d="$(printf -- "$d" | jq -c)"
			fi

			data="-d '${d}' -H 'Content-Type: ${content_type}'"

			curl_command="$curl_command $data"
		fi

		curl_command="$curl_command --request $method \"$scheme://$host$port$path\""
		eval curl_output=\"\$\($curl_command\)\"

		newline
		text -m "**CURL Command:**"
		text    "  $curl_command"

		json=false
		xml=false
		curl_header_response=
		curl_header=
		curl_body=
		curl_head=true

		while IFS= read -r line
		do 

			line="$(printf -- "$line" | sed "s/\r//g;s/\n//g")"
			if [ "$curl_head" = "true" ]; then

				if [ -z "$line" ]; then
					curl_head=false
				else
					if [ ! -z "$(printf -- "$line" | grep "Content-Type")" ]; then
						if [ ! -z "$(printf -- "$line" | grep "json")" ]; then
							json=true
						elif [ ! -z "$(printf -- "$line" | grep "xml")" ] || [ ! -z "$(printf -- "$line" | grep "html")" ]; then
							xml=true
						fi
					fi

					if [ -z "$curl_header" ]; then
						curl_header="$line"
						curl_header_response="$curl_header"
					else
						curl_header="$(printf -- "$curl_header\n$line")"
					fi
				fi
			else
				if [ -z "$curl_body" ]; then
					curl_body="$line"
				else
					curl_body="$(printf -- "$curl_body\n$line")"
				fi
			fi
		done <<- EOF
		$curl_output
		EOF

		if [ ! -z "$curl_header_response" ]; then
			newline
			printf -- "$curl_header_response"
			newline
		fi

		newline
		if [ "$json" = "true" ]; then
			printf -- "$curl_body" | jq .
		elif [ "$xml" = "true" ]; then
			printf -- "$curl_body" | xq -x .
		else
			cat <<- HERE | jq .
			{
				"status": $?,
				"message": "Bad response! (not JSON, XML, or HTML)"
			}
			HERE
		fi
	)
}

user-install-software() (
	soft_home=
	soft_dmg_vol=
	soft_tar_args=
	soft_zip_prefix=
	soft_dmg_app=
	soft_save_download_file=true
	while [ -z "${1%%-*}" ]
	# while [ "${1:0:1}" = "-" ] || [ "${1:0:2}" = "--" ]
	do
		case $1 in
			"--home" )
				shift
				soft_home="$1"
				shift
				;;
			"--tar-args" )
				shift
				soft_tar_args="$1"
				shift
				;;
			"--zip-prefix" )
				shift
				soft_zip_prefix="$1"
				shift
				;;
			"--dmg-vol" )
				shift
				soft_dmg_vol="$1"
				shift
				;;
			"--dmg-app" )
				shift
				soft_dmg_app="$1"
				shift
				;;
			"--save-download-file" )
				shift
				soft_save_download_file="$1"
				shift
				;;
			"--" )
				shift
				;;
			*)
				;;
		esac
	done

	soft_download_url="$1"
	soft_saved_download_location="$2"

	if [ "$soft_save_download_file" = "true" ] && [ ! -f "$soft_saved_download_location" ]; then
		curl -L -o "$soft_saved_download_location" "$soft_download_url"
	fi

	if [ -f "$soft_saved_download_location" ]; then
		case "$soft_saved_download_location" in
			*.zip )
				mkdir -p "$DF_DOWNLOADS_HOME/tmp"
				unzip "$soft_saved_download_location" -d "$DF_DOWNLOADS_HOME/tmp"
				mkdir -p "$soft_home"
				mv "$DF_DOWNLOADS_HOME/tmp/${soft_zip_prefix}"* "$soft_home"
				rm -rf "$DF_DOWNLOADS_HOME/tmp"

				;;

			*.tar.xz )
				mkdir -p "$soft_home"

				if [ "$soft_save_download_file" = "true" ]; then
					tar -xJf "$soft_saved_download_location" -C "$soft_home" "$soft_tar_args"
				else
					curl "$soft_download_url" | tar -xJ -C "$soft_home" "$soft_tar_args"
				fi

				;;

			*.tar.gz )
				mkdir -p "$soft_home"

				if [ "$soft_save_download_file" = "true" ]; then
					tar -xzf "$soft_saved_download_location" -C "$soft_home" "$soft_tar_args"
				else
					curl "$soft_download_url" | tar -xz -C "$soft_home" "$soft_tar_args"
				fi

				;;

			*.dmg )
				mkdir -p "$soft_home"

				hdiutil attach "$soft_saved_download_location"
				cp -R "/Volumes/${soft_dmg_vol}/${soft_dmg_app}" "$soft_home"
				hdiutil detach "/Volumes/${soft_dmg_vol}"

				;;

			* )
				;;
		esac
	fi
)
