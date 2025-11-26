if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
	export ZED_HOME="$DF_APP_HOME/Zed.app"
	if [ -d "${ZED_HOME}/Contents/MacOS" ]; then
		export ZED_OPT_HOME="$DF_SOFTWARE_HOME/zed"
		export PATH="$ZED_OPT_HOME/bin:$PATH"
		export EDITOR="zed --wait"

		if [ ! -L "$ZED_OPT_HOME/bin/zed" ]; then
			mkdir -p "$ZED_OPT_HOME/bin"
			ln -snf "$ZED_HOME/Contents/MacOS/cli" "$ZED_OPT_HOME/bin/zed"
		fi
	fi
fi
