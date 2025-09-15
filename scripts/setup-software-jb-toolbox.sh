: ${DF_SETUP_JB_TOOLBOX:="false"}
if [ "$DF_SETUP_JB_TOOLBOX" = "true" ]; then
	# https://www.jetbrains.com/toolbox-app/download/other.html
	: ${DF_JB_TOOLBOX_VERSION:="2.8.1.52155"}

	(
		if [ ! -f "$DF_APP_HOME/jetbrains-toolbox" ] && [ ! -d "$DF_APP_HOME/JetBrains Toolbox.app" ]; then
			cat <<- HERE
			Installing JetBrains Toolbox (version $DF_JB_TOOLBOX_VERSION)...
			HERE

			suffix=
			if [ "$DF_OS" = "$DF_OS_WINDOWS" ]; then
				suffix=".win.zip"
			elif [ "$DF_OS" = "$DF_OS_LINUX" ]; then
				suffix=".tar.gz"
			elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
				if [ "$DF_ARCH" = "$DF_ARCH_ARM64" ]; then
					suffix="-arm64.dmg"
				else
					suffix=".dmg"
				fi
			fi

			download_url="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}${suffix}"
			saved_download_location=$DF_DOWNLOADS_HOME/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}${suffix}

			user-install-software --home "$DF_APP_HOME" --tar-args "--strip-components=1" --dmg-vol "JetBrains Toolbox" --dmg-app "JetBrains Toolbox.app" "$download_url" "$saved_download_location"
		fi
	)
fi