# Install steps that are the same whichever shell is being set up. Sourced by
# install-bash and install-zsh, both of which write these exact files, so they
# live here rather than being duplicated and left to drift apart.
#
# Expects "$dotfiles_dir" to be set and scripts/install-lib.sh to be sourced.

ln -snf "$dotfiles_dir/.tmux.conf" "$HOME/.tmux.conf"

# "$HOME/.dfrc" - the single entry point both .zshrc and .bashrc source
if [ ! -f "$HOME/.dfrc" ]; then
	# carry over a pre-rename entry point so hand-written additions survive
	if [ -f "$HOME/.dfzsh" ]; then
		mv "$HOME/.dfzsh" "$HOME/.dfrc"
	elif [ -f "$HOME/.dotfiles.zsh" ]; then
		mv "$HOME/.dotfiles.zsh" "$HOME/.dfrc"
	fi
fi

# the pre-rename entry point set DOTFILES_DIR on a bare line, before there were
# markers to delimit it - drop it or the old path survives the upgrade. only for
# an unmarked file; once markers are in place df-install-block owns that line
if [ -f "$HOME/.dfrc" ] && ! grep -q "$df_install_match" "$HOME/.dfrc"; then
	mv "$HOME/.dfrc" "$HOME/.dfrc.bak"
	sed "/export DOTFILES_DIR/d" "$HOME/.dfrc.bak" >"$HOME/.dfrc"
fi

# top, because everything a user adds below it builds on DOTFILES_DIR. only one
# of the two source lines can fire - the other shell's version variable is unset
df-install-block "$HOME/.dfrc" top <<-HERE
	export DOTFILES_DIR="$dotfiles_dir"

	[ -n "\$ZSH_VERSION" ] && [ -f "\$DOTFILES_DIR/sh/zsh/rc.sh" ] && . "\$DOTFILES_DIR/sh/zsh/rc.sh"
	[ -n "\$BASH_VERSION" ] && [ -f "\$DOTFILES_DIR/sh/bash/rc.sh" ] && . "\$DOTFILES_DIR/sh/bash/rc.sh"
HERE
