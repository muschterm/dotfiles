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
			alias -g ls.command="gls --group-directories-first"
		elif command -v coreutils >/dev/null 2>&1; then
			alias -g ls.command="coreutils ls --group-directories-first"
		else
			alias -g ls.command="ls"
		fi
	elif [ "$DF_OS" = "$DF_OS_LINUX" ]; then
		alias -g ls.command="ls --group-directories-first"
	fi

	alias ls="ls.command -X --color"
	alias la="ls -Al"
fi

. "$DOTFILES_DIR/sh/posix/docker/aliases.sh"
