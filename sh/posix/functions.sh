# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() (
	if [ $# -ne 2 ]; then
		if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
			cat <<-HERE
				Usage: iso2sd <input_file> <output_device>
				Example: iso2sd ~/Downloads/foo.iso /dev/disk4
			HERE

			printf -- "\nAvailable SD cards:\n"
			diskutil list external physical
		else
			cat <<-HERE
				Usage: iso2sd <input_file> <output_device>
				Example: iso2sd ~/Downloads/foo.iso /dev/sda
			HERE

			printf -- "\nAvailable SD cards:\n"
			lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
		fi

		return 1
	fi

	if [ ! -f "$1" ]; then
		printf -- "No such input file: %s\n" "$1" >&2
		return 1
	fi

	# sudo resets PATH, so resolve dd here and run it by absolute path;
	# coreutils on macos provides gnu dd as gdd, which reports progress
	iso_dd="$(command -v gdd || command -v dd)"

	if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		# accept disk4, /dev/disk4 or /dev/rdisk4 -- diskutil wants the buffered
		# device while dd is much faster against the raw one, which also skips
		# the buffer cache and makes oflag=sync pointless
		iso_disk="${2#/dev/}"
		iso_disk="${iso_disk#r}"
		iso_device="/dev/r$iso_disk"
		iso_disk="/dev/$iso_disk"

		diskutil unmountDisk "$iso_disk" || return 1
	else
		iso_device="$2"
	fi

	# bs=4M is understood by both, the rest is gnu only
	if ! "$iso_dd" --version >/dev/null 2>&1; then
		printf -- "Writing %s to %s, press ctrl-t for progress...\n" "$1" "$iso_device"
		sudo "$iso_dd" bs=4M if="$1" of="$iso_device"
	elif [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		sudo "$iso_dd" bs=4M status=progress if="$1" of="$iso_device"
	else
		sudo "$iso_dd" bs=4M status=progress oflag=sync if="$1" of="$iso_device"
	fi || return 1

	if [ "$DF_OS" = "$DF_OS_MACOS" ]; then
		sync
		diskutil eject "$iso_disk"
	else
		sudo eject "$2"
	fi
)

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
