#!/usr/bin/env sh

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
