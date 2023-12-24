#!/usr/bin/env sh

# reset
export DF_ATTR_RESET_ALL="0"
export DF_ATTR_RESET_BOLD="21"
export DF_ATTR_RESET_DIM="22"
# if [ "${TERM:0:5}" = "xterm" ]; then
if [ ! -z "$TERM" ] && [ -z "${TERM%%xterm*}" ]; then
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
