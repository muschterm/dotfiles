# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() {
	if [ $# -ne 2 ]; then
		cat <<-HERE
			Usage: iso2sd <input_file> <output_device>
			Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda
		HERE

		if [ "$DF_OS" = "$DF_OS_LINUX" ]; then
			printf -- "\nAvailable SD cards:\n"
			lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
		fi
	else
		sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
		sudo eject $2
	fi
}

if [ "$DF_OS" = "$DF_OS_LINUX" ]; then

	# Format an entire drive for a single partition using ext4
	format-drive() {
		if [ $# -ne 2 ]; then
			cat <<-HERE
				Usage: format-drive <device> <name>
				Example: format-drive /dev/sda 'My Stuff'

				Available drives:
			HERE

			lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
		else
			cat <<-HERE
				WARNING: This will completely erase all data on $1 and label it '$2'.

				Are you sure you want to continue? [Y/n]
			HERE
			read continue
			case $continue in
			"y" | "Y" | "yes" | "Yes" | "YES")
				sudo wipefs -a "$1"
				sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
				sudo parted -s "$1" mklabel gpt
				sudo parted -s "$1" mkpart primary ext4 1MiB 100%
				sudo mkfs.ext4 -L "$2" "$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
				sudo chmod -R 777 "/run/media/$USER/$2"
				echo "Drive $1 formatted and labeled '$2'."
				;;
			*)
				printf -- "skipped\n"
				exit 0
				;;
			esac
		fi
	}

	if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1; then
		setup-passwordless-sudo() {
			local_user="$(whoami)"
			if [ ! -f "/etc/sudoers.d/${local_user}" ]; then
				printf -- "Setting up passwordless sudo!\n\n"

				sudo touch "/etc/sudoers.d/${local_user}"
				sudo chmod 0777 "/etc/sudoers.d/${local_user}"

				cat <<-HERE >"/etc/sudoers.d/${local_user}"
					${local_user} ALL=(ALL) NOPASSWD: ALL
				HERE

				sudo chmod 0440 "/etc/sudoers.d/${local_user}"
			fi
		}
	fi

fi

# supports downloading and installing software
# should use mise or other tools first, then fallback to this if needed
df-user-install-software() (
	soft_home=
	soft_dmg_vol=
	soft_tar_args=
	soft_zip_prefix=
	soft_dmg_app=
	soft_save_download_file=true
	while [ -z "${1%%-*}" ]; do # while [ "${1:0:1}" = "-" ] || [ "${1:0:2}" = "--" ]
		case $1 in
		"--home")
			shift
			soft_home="$1"
			shift
			;;
		"--tar-args")
			shift
			soft_tar_args="$1"
			shift
			;;
		"--dmg-vol")
			shift
			soft_dmg_vol="$1"
			shift
			;;
		"--dmg-app")
			shift
			soft_dmg_app="$1"
			shift
			;;
		"--save-download-file")
			shift
			soft_save_download_file="$1"
			shift
			;;
		"--")
			shift
			;;
		*) ;;
		esac
	done

	soft_download_url="$1"
	soft_saved_download_location="$2"

	if [ "$soft_save_download_file" = "true" ] && [ ! -f "$soft_saved_download_location" ]; then
		curl -L -o "$soft_saved_download_location" "$soft_download_url"
	fi

	if [ -f "$soft_saved_download_location" ]; then
		case "$soft_saved_download_location" in
		*.zip)
			mkdir -p "$soft_home"
			unzip "$soft_saved_download_location" -d "$soft_home"
			;;

		*.tar.xz | *.txz)
			mkdir -p "$soft_home"

			if [ "$soft_save_download_file" = "true" ]; then
				tar -xJf "$soft_saved_download_location" -C "$soft_home" "$soft_tar_args"
			else
				curl "$soft_download_url" | tar -xJ -C "$soft_home" "$soft_tar_args"
			fi

			;;

		*.tar.gz | *.tgz)
			mkdir -p "$soft_home"

			if [ "$soft_save_download_file" = "true" ]; then
				tar -xzf "$soft_saved_download_location" -C "$soft_home" "$soft_tar_args"
			else
				curl "$soft_download_url" | tar -xz -C "$soft_home" "$soft_tar_args"
			fi

			;;

		*.dmg)
			mkdir -p "$soft_home"

			hdiutil attach "$soft_saved_download_location"
			cp -R "/Volumes/${soft_dmg_vol}/${soft_dmg_app}" "$soft_home"
			hdiutil detach "/Volumes/${soft_dmg_vol}"

			;;

		*) ;;
		esac
	fi
)
