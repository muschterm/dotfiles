#!/usr/bin/env sh

: ${DF_SETUP_JB_TOOLBOX:="false"}
if [ "$DF_SETUP_JB_TOOLBOX" = "true" ]; then
	: ${DF_JB_TOOLBOX_VERSION:="1.17.7275"}

	(
		if [ ! -f "$DF_APP_HOME/jetbrains-toolbox" ] && [ ! -d "$DF_APP_HOME/JetBrains Toolbox.app" ]; then
			cat <<- HERE
			Installing JetBrains Toolbox (version $DF_JB_TOOLBOX_VERSION)...
			HERE

			download_url=
			saved_download_location=

			local_jb_toolbox_download_url="https://download.jetbrains.com/toolbox"
			if [ "$DF_OS_WINDOWS" = "true" ]; then
				download_url="$local_jb_toolbox_download_url/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}.win.zip"
				saved_download_location="$DF_DOWNLOADS_HOME/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}.win.zip"
			elif [ "$DF_OS_LINUX" = "true" ]; then
				download_url="$local_jb_toolbox_download_url/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}.tar.gz"
				saved_download_location="$DF_DOWNLOADS_HOME/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}.tar.gz"
			elif [ "$DF_OS_MACOS" = "true" ]; then
				download_url="$local_jb_toolbox_download_url/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}.dmg"
				saved_download_location="$DF_DOWNLOADS_HOME/jetbrains-toolbox-${DF_JB_TOOLBOX_VERSION}.dmg"
			fi

			user-install-software --home "$DF_APP_HOME" --zip-prefix "jetbrains-toolbox" --tar-args "--strip-components=1" --dmg-vol "JetBrains Toolbox" --dmg-app "JetBrains Toolbox.app" "$download_url" "$saved_download_location"
		fi
	)
fi