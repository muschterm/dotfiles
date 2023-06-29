#!/usr/bin/env sh

: ${DF_SETUP_VSCODE:="false"}
if [ "${DF_SETUP_VSCODE}" = "true" ]; then
	if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		local_vscode_app="$DF_APP_HOME/Visual Studio Code.app"
		[ -d "${local_vscode_app}/Contents" ] && export PATH="${local_vscode_app}/Contents/Resources/app/bin:$PATH"
		unset local_vscode_app
	fi
fi
