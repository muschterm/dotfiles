: ${DOTFILES_DIR:="/opt/dotfiles"}

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

##########################
# Shared
##########################

. "$DOTFILES_DIR/sh/posix/envs.sh"
. "$DOTFILES_DIR/sh/posix/shell.sh"
. "$DOTFILES_DIR/sh/posix/functions.sh"
. "$DOTFILES_DIR/sh/posix/init.sh"

##########################
# Initialize zsh completion
##########################

# Zsh always supports completion if compinit exists
autoload -Uz compinit
if typeset -f compinit >/dev/null 2>&1; then
	export DF_ZSH_COMPLETIONS_DIR="$DF_HOME/zsh/completions"
	[ ! -d "$DF_ZSH_COMPLETIONS_DIR" ] && mkdir -p "$DF_ZSH_COMPLETIONS_DIR"

	__df-set-completions-zsh() {
		if [ $# -ne 2 ]; then
			cat <<-HERE
				Usage:   set-completions-zsh <name_as_string> <completion_script_as_string>
				Example: set-completions-zsh 'mise' 'mise completion zsh'
			HERE
		else
			df_completion_file="$DF_ZSH_COMPLETIONS_DIR/_$1"

			echo "Generating $1 completion script…"
			if eval $2 >"$df_completion_file"; then
				echo "✔ Saved: $df_completion_file"
			else
				echo "✖ Error: Failed to generate $1 completion" >&2
				return 1
			fi

			zcompile "$df_completion_file.zwc" "$df_completion_file"

			unset df_completion_file

			cat <<-HERE
				✔ Done. After upgrading ${1}, call set-completions-${1} to regenerate completions.
			HERE
		fi
	}
fi

##########################
# Software
##########################

. "$DOTFILES_DIR/sh/posix/mise/rc.sh"
. "$DOTFILES_DIR/sh/zsh/mise/rc.sh"

. "$DOTFILES_DIR/sh/posix/starship/rc.sh"
. "$DOTFILES_DIR/sh/zsh/starship/rc.sh"

. "$DOTFILES_DIR/sh/zsh/docker/rc.sh"

. "$DOTFILES_DIR/sh/posix/jb-toolbox/rc.sh"

. "$DOTFILES_DIR/sh/posix/sublime/rc.sh"

. "$DOTFILES_DIR/sh/posix/zed/rc.sh"

. "$DOTFILES_DIR/sh/posix/vscode/rc.sh"

. "$DOTFILES_DIR/sh/zsh/deno/rc.sh"

. "$DOTFILES_DIR/sh/posix/node/rc.sh"
. "$DOTFILES_DIR/sh/zsh/node/rc.sh"

. "$DOTFILES_DIR/sh/posix/quarkus/rc.sh"

##########################
# Aliases
##########################

. "$DOTFILES_DIR/sh/posix/aliases.sh"

##########################
# Finalize zsh completion
##########################

if typeset -f __df-set-completions-zsh >/dev/null 2>&1; then
	export FPATH="$DF_ZSH_COMPLETIONS_DIR:$FPATH"

	# -C to skip the security scan - significantly faster on MacOS/WSL
	# Keeping -C breaks completions sometimes.
	compinit
fi
