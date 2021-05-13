#!/usr/bin/env sh

: ${DF_SETUP_NODEJS:="false"}
if [ "$DF_SETUP_NODEJS" = "true" ]; then
	# : ${DF_NODEJS_VERSION:="12.22.1"}
	: ${DF_NODEJS_VERSION:="14.17.0"}
	export NODEJS_HOME="$DF_SOFTWARE_HOME/node-v${DF_NODEJS_VERSION}"
	
	export PATH="$NODEJS_HOME/bin:$PATH"

	(
		if [ ! -d "$NODEJS_HOME" ]; then
			cat <<- HERE
			Installing Node JS (version $DF_NODEJS_VERSION)...
			HERE

			download_url=
			saved_download_location=

			local_nodejs_download_url="https://nodejs.org/dist/v${DF_NODEJS_VERSION}"
			if [ "$DF_OS_WINDOWS" = "true" ]; then
				download_url="$local_nodejs_download_url/node-v${DF_NODEJS_VERSION}-win-x64.zip"
				saved_download_location="$DF_DOWNLOADS_HOME/node-v${DF_NODEJS_VERSION}-win-x64.zip"
			elif [ "$DF_OS_LINUX" = "true" ]; then
				download_url="$local_nodejs_download_url/node-v${DF_NODEJS_VERSION}-linux-x64.tar.gz"
				saved_download_location="$DF_DOWNLOADS_HOME/node-v${DF_NODEJS_VERSION}-linux-x64.tar.gz"
			elif [ "$DF_OS_MACOS" = "true" ]; then
				download_url="$local_nodejs_download_url/node-v${DF_NODEJS_VERSION}-darwin-x64.tar.gz"
				saved_download_location="$DF_DOWNLOADS_HOME/node-v${DF_NODEJS_VERSION}-darwin-x64.tar.gz"
			fi

			user-install-software --home "$NODEJS_HOME" --zip-prefix "node-" --tar-args "--strip-components=1" "$download_url" "$saved_download_location"
		fi
	)
fi

# npm config setup
if [ "$(which npm &>/dev/null; printf -- "$?")" = "0" ]; then
	local_npm_prefix="${HOME}/.npm-packages"
	if [ -f "${HOME}/.npmrc"  ] && [ "$(cat "${HOME}/.npmrc" | grep "${local_npm_prefix}")" != "prefix=${local_npm_prefix}" ]; then
		npm config set prefix "${local_npm_prefix}"
	fi

	export PATH="$local_npm_prefix/bin:$PATH"

	unset local_npm_prefix
fi
