: ${DF_SETUP_NODEJS:="false"}
if [ "$DF_SETUP_NODEJS" = "true" ]; then
	: ${DF_NODEJS_VERSION:="20.18.1"}
	export NODEJS_HOME="$DF_SOFTWARE_HOME/node-v${DF_NODEJS_VERSION}"

	export PATH="$NODEJS_HOME/bin:$PATH"

	(
		if [ ! -d "$NODEJS_HOME" ]; then
			cat <<-HERE
				Installing Node JS (version $DF_NODEJS_VERSION)...
			HERE

			download_url=
			saved_download_location=

			local_nodejs_download_url="https://nodejs.org/dist/v${DF_NODEJS_VERSION}"
			if [ "$DF_OS" = "$DF_OS_WINDOWS" ]; then
				download_url="$local_nodejs_download_url/node-v${DF_NODEJS_VERSION}-win-x64.zip"
				saved_download_location="$DF_DOWNLOADS_HOME/node-v${DF_NODEJS_VERSION}-win-x64.zip"
			elif [ "$DF_OS" = "$DF_OS_LINUX" ]; then
				download_url="$local_nodejs_download_url/node-v${DF_NODEJS_VERSION}-linux-x64.tar.gz"
				saved_download_location="$DF_DOWNLOADS_HOME/node-v${DF_NODEJS_VERSION}-linux-x64.tar.gz"
			elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
				suffix=
				if [ "$DF_ARCH" = "$DF_ARCH_ARM_64" ]; then
					suffix="-arm64.tar.gz"
				else
					suffix="-x64.tar.gz"
				fi

				download_url="$local_nodejs_download_url/node-v${DF_NODEJS_VERSION}-darwin${suffix}"
				saved_download_location="$DF_DOWNLOADS_HOME/node-v${DF_NODEJS_VERSION}-darwin${suffix}"
			fi

			user-install-software --home "$NODEJS_HOME" --tar-args "--strip-components=1" "$download_url" "$saved_download_location"
		fi
	)
fi

# npm config setup
# if command -v npm > /dev/null; then
# 	local_npm_prefix="${HOME}/.npm-packages"
# 	if [ -f "${HOME}/.npmrc"  ] && [ "$(cat "${HOME}/.npmrc" | grep "${local_npm_prefix}")" != "prefix=${local_npm_prefix}" ]; then
# 		npm config set prefix "${local_npm_prefix}"
# 	fi

# 	export PATH="$local_npm_prefix/bin:$PATH"

# 	unset local_npm_prefix
# fi
