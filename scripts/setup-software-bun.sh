: ${DF_SETUP_BUN:="false"}
if [ "${DF_SETUP_BUN}" = "true" ]; then
	: ${BUN_INSTALL:="$HOME/.bun"}

	export PATH="$BUN_INSTALL/bin:$PATH"

	if [ ! -d "$BUN_INSTALL" ]; then
		cat <<-HERE
			Installing Bun into "$BUN_INSTALL"...
		HERE

		(
			curl -fsSL https://bun.sh/install | bash
		)

		cat <<-HERE
			# after upgrading bun, run to ensure completions are accurate:
			bun completions
		HERE
	fi

	# completions
	if [ ! -f "$BUN_INSTALL/_bun" ]; then
		bun completions
	fi

	[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

fi
