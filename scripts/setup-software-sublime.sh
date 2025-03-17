: ${DF_SETUP_SUBLIME:="false"}
if [ "${DF_SETUP_SUBLIME}" = "true" ]; then
	if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		local_sublime_text_app="${DF_APP_HOME}/Sublime Text.app"
		[ -d "${local_sublime_text_app}/Contents" ] && export PATH="${local_sublime_text_app}/Contents/SharedSupport/bin:$PATH"
		unset local_sublime_text_app

		local_sublime_merge_app="${DF_APP_HOME}/Sublime Merge.app"
		[ -d "${local_sublime_merge_app}/Contents" ] && export PATH="${local_sublime_merge_app}/Contents/SharedSupport/bin:$PATH"
		unset local_sublime_merge_app
	fi
fi
