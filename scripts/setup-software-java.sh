: ${DF_SETUP_OPENJDK:="false"}
if [ "$DF_SETUP_OPENJDK" = "true" ]; then
	: ${DF_OPENJDK_VERSION:="16.0.1"}

	(
		install_openjdk() {
			local_openjdk_version="$1"
			openjdk_download_url="$2"

			jdk_home="$DF_SOFTWARE_HOME/jdk-${local_openjdk_version}"
			if [ ! -d "$jdk_home" ]; then
				cat <<-HERE
					Installing OpenJDK (version $local_openjdk_version)...
				HERE

				download_url=
				saved_download_location=

				if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
					download_url="$openjdk_download_url/openjdk-${local_openjdk_version}_linux-x64_bin.tar.gz"
					saved_download_location="$DF_DOWNLOADS_HOME/openjdk-${local_openjdk_version}_linux-x64_bin.tar.gz"
				elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
					download_url="$openjdk_download_url/openjdk-${local_openjdk_version}_osx-x64_bin.tar.gz"
					saved_download_location="$DF_DOWNLOADS_HOME/openjdk-${local_openjdk_version}_osx-x64_bin.tar.gz"
				elif [ "$DF_OS" = "$DF_OS_WINDOWS" ]; then
					download_url="$openjdk_download_url/openjdk-${local_openjdk_version}_windows-x64_bin.zip"
					saved_download_location="$DF_DOWNLOADS_HOME/openjdk-${local_openjdk_version}_windows-x64_bin.zip"
				fi

				if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
					user-install-software --home "$jdk_home" --tar-args "--strip-components=4 jdk-${local_openjdk_version}.jdk/Contents/Home" "$download_url" "$saved_download_location"
				else
					user-install-software --home "$jdk_home" --tar-args "--strip-components=1" "$download_url" "$saved_download_location"
				fi
			fi
		}

		install_openjdk '16.0.1' 'https://download.java.net/java/GA/jdk16.0.1/7147401fd7354114ac51ef3e1328291f/9/GPL'
		install_openjdk '17-ea+21' 'https://download.java.net/java/early_access/jdk17/21/GPL'
	)

	[ -z "$JAVA_HOME" ] && export JAVA_HOME="$DF_SOFTWARE_HOME/jdk-${DF_OPENJDK_VERSION}"
	export PATH="$JAVA_HOME/bin:$PATH"
fi
