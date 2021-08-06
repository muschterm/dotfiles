#!/usr/bin/env zsh

oh_my_zsh_install_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

if [ "$(which curl &>/dev/null; printf -- "$?")" = "0" ]; then
	sh -c "$(curl -fsSL "$oh_my_zsh_install_url")"
elif [ "$(which wget &>/dev/null; printf -- "$?")" = "0" ]; then
	sh -c "$(wget -O- "$oh_my_zsh_install_url")"
else
	printf -- "Cannot install Oh My Zsh - missing curl or wget.\n"
fi
