: ${DOTFILES_DIR:="/opt/dotfiles"}

##########################
# Shared
##########################

. "$DOTFILES_DIR/sh/posix/envs.sh"
. "$DOTFILES_DIR/sh/posix/shell.sh"
. "$DOTFILES_DIR/sh/posix/functions.sh"
. "$DOTFILES_DIR/sh/posix/init.sh"

##########################
# Initialize bash completion
##########################

if type complete >/dev/null 2>&1; then
	if type _init_completion >/dev/null 2>&1 ||
		[ -f /usr/share/bash-completion/bash_completion ] ||
		[ -f /opt/homebrew/etc/profile.d/bash_completion.sh ] ||
		[ -f /usr/local/etc/profile.d/bash_completion.sh ] ||
		[ -f /usr/share/git/completion/git-completion.bash ] ||
		[ -f /mingw64/share/git/completion/git-completion.bash ]; then
		export DF_BASH_COMPLETIONS_DIR="$DF_HOME/bash/completions"
		[ ! -d "$DF_BASH_COMPLETIONS_DIR" ] && mkdir -p "$DF_BASH_COMPLETIONS_DIR"

		__df-set-completions-bash() {
			if [ $# -ne 2 ]; then
				cat <<-HERE
					Usage:   set-completions-bash <name_as_string> <completion_script_as_string>
					Example: set-completions-bash 'mise' 'mise completion bash'
				HERE
			else
				df_completion_file="$DF_BASH_COMPLETIONS_DIR/_$1"

				echo "Generating $1 completion script…"
				if eval $2 >"$df_completion_file"; then
					echo "✔ Saved: $df_completion_file"
				else
					echo "✖ Error: Failed to generate $1 completion" >&2
					return 1
				fi

				unset df_completion_file

				cat <<-HERE
					✔ Done. After upgrading ${1}, call set-completions-${1} to regenerate completions.
				HERE
			fi
		}

		if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
			# Git
			[ -r "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash" ] && . "/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash"
		fi
	fi
fi

##########################
# Software
##########################

. "$DOTFILES_DIR/sh/posix/mise/rc.sh"
. "$DOTFILES_DIR/sh/bash/mise/rc.sh"

. "$DOTFILES_DIR/sh/posix/starship/rc.sh"
. "$DOTFILES_DIR/sh/bash/starship/rc.sh"

. "$DOTFILES_DIR/sh/bash/docker/rc.sh"

. "$DOTFILES_DIR/sh/posix/jb-toolbox/rc.sh"

. "$DOTFILES_DIR/sh/posix/sublime/rc.sh"

. "$DOTFILES_DIR/sh/posix/zed/rc.sh"

. "$DOTFILES_DIR/sh/posix/vscode/rc.sh"

. "$DOTFILES_DIR/sh/bash/deno/rc.sh"

. "$DOTFILES_DIR/sh/posix/node/rc.sh"
. "$DOTFILES_DIR/sh/bash/node/rc.sh"

. "$DOTFILES_DIR/sh/posix/quarkus/rc.sh"

##########################
# Aliases
##########################

. "$DOTFILES_DIR/sh/posix/aliases.sh"

##########################
# Finalize bash completion
##########################

if typeset -f __df-set-completions-bash >/dev/null 2>&1; then
	for f in "$DF_BASH_COMPLETIONS_DIR"/_*; do
		[ -r $f && -f $f ] || continue
		. "$f"
	done
fi
