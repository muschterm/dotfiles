#!/usr/bin/env sh

##################################################
#
# This is useful for handling step by step scripts that should
# fail completely if a single step fails.
#
##################################################

handle_error() {
	printf -- "\033[0m"
	fail "unsuccessful"
}

handle_exit() {
	if [ $? != 0 ]; then
		handle_error
	fi
}

set -e

trap handle_error INT
trap handle_error TERM
trap handle_error KILL
trap handle_exit EXIT
