if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
	local_vscode_app="$DF_APP_HOME/Visual Studio Code.app"
	[ -d "${local_vscode_app}/Contents" ] && df-path-prepend "${local_vscode_app}/Contents/Resources/app/bin"
	unset local_vscode_app
fi
