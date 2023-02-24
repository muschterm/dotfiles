#!/usr/bin/env sh

: ${DF_SETUP_GOLANG:="false"}
if [ "$DF_SETUP_GOLANG" = "true" ]; then
	: ${DF_GOLANG_VERSION:="1.12.7"}
	export GOROOT="$DF_SOFTWARE_HOME/go-${DF_GOLANG_VERSION}"
	
	# setup GOPATH
	[ -z "$GOPATH" ] && export GOPATH="$HOME/go"

	export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

	(
		if [ ! -d "$GOROOT" ]; then
			cat <<- HERE
			Installing Golang (version $DF_GOLANG_VERSION)...
			HERE

			download_url=
			saved_download_location=

			local_golang_download_url="https://dl.google.com/go"
			if [ "$DF_OS" = "$DF_OS_WINDOWS" ]; then
				download_url="$local_golang_download_url/go${DF_GOLANG_VERSION}.windows-amd64.zip"
				saved_download_location="$DF_DOWNLOADS_HOME/go${DF_GOLANG_VERSION}.windows-amd64.zip"
			elif [ "$DF_OS" = "$DF_OS_LINUX" ]; then
				download_url="$local_golang_download_url/go${DF_GOLANG_VERSION}.linux-amd64.tar.gz"
				saved_download_location="$DF_DOWNLOADS_HOME/go${DF_GOLANG_VERSION}.linux-amd64.tar.gz"
			elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
				download_url="$local_golang_download_url/go${DF_GOLANG_VERSION}.darwin-amd64.tar.gz"
				saved_download_location="$DF_DOWNLOADS_HOME/go${DF_GOLANG_VERSION}.darwin-amd64.tar.gz"
			fi

			user-install-software --home "$GOROOT" --tar-args "--strip-components=1" "$download_url" "$saved_download_location"
		fi
	)
fi