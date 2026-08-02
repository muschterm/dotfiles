###############################################################################
# Aliases                                                                     #
###############################################################################
if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
	alias open="xdg-open > /dev/null 2>&1"
	alias copy="xclip -selection clipboard"
elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
	alias copy="pbcopy"
fi

if command -v nvim >/dev/null 2>&1; then
	alias n="nvim"
fi

if command -v eza >/dev/null 2>&1; then
	alias ls="eza --sort extension --group-directories-first --icons=auto"
	alias la="ls --all --long --group --time-style=long-iso"
	alias lt="ls --no-permissions --no-user --no-time --no-filesize --all --long --tree --level"
else
	if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		if command -v gls >/dev/null 2>&1; then
			alias ls="gls --group-directories-first -X --color=auto"
		elif command -v coreutils >/dev/null 2>&1; then
			alias ls="coreutils ls --group-directories-first -X --color=auto"
		else
			# BSD ls: no -X and no --color
			alias ls="ls -G"
		fi
	elif [ "$DF_OS" = "$DF_OS_LINUX" ]; then
		alias ls="ls --group-directories-first -X --color=auto"
	fi

	alias la="ls -Al"
fi

. "$DOTFILES_DIR/sh/posix/docker/aliases.sh"
