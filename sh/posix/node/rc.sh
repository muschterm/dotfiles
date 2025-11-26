# npm config setup
# if command -v npm > /dev/null; then
# 	local_npm_prefix="${HOME}/.npm-packages"
# 	if [ -f "${HOME}/.npmrc"  ] && [ "$(cat "${HOME}/.npmrc" | grep "${local_npm_prefix}")" != "prefix=${local_npm_prefix}" ]; then
# 		npm config set prefix "${local_npm_prefix}"
# 	fi

# 	export PATH="$local_npm_prefix/bin:$PATH"

# 	unset local_npm_prefix
# fi
