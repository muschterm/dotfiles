###############################################################################
# Variables                                                                   #
###############################################################################
DF_OS=
DF_OS_LINUX="linux"
DF_OS_MACOS="macos"
DF_OS_WINDOWS="windows"
DF_WSL="false"
case "$(uname -r)" in
*microsoft*)
    DF_WSL="true"
    ;;
*) ;;
esac

case "$(uname -s)" in
"Linux")
    DF_OS=$DF_OS_LINUX

    [ -z "$DF_HOME" ] && export DF_HOME="$HOME/.dotfiles.d"
    [ -z "$DF_DOWNLOADS_HOME" ] && export DF_DOWNLOADS_HOME="$DF_HOME/downloads"
    [ -z "$DF_SOFTWARE_HOME" ] && export DF_SOFTWARE_HOME="$DF_HOME/opt"
    [ -z "$DF_APP_HOME" ] && export DF_APP_HOME="$DF_HOME/app"
    ;;
"Darwin")
    DF_OS=$DF_OS_MACOS

    [ -z "$DF_HOME" ] && export DF_HOME="$HOME/.dotfiles.d"
    [ -z "$DF_DOWNLOADS_HOME" ] && export DF_DOWNLOADS_HOME="$DF_HOME/downloads"
    [ -z "$DF_SOFTWARE_HOME" ] && export DF_SOFTWARE_HOME="$DF_HOME/opt"
    [ -z "$DF_APP_HOME" ] && export DF_APP_HOME="/Applications"
    ;;
"MSYS"* | "MINGW"* | "CYGWIN"*)
    DF_OS=$DF_OS_WINDOWS
    : ${DEV_WINDOWS_DRIVELETTER:="c"}

    [ -z "$DF_HOME" ] && export DF_HOME="/$DEV_WINDOWS_DRIVELETTER/dotfiles"
    [ -z "$DF_DOWNLOADS_HOME" ] && export DF_DOWNLOADS_HOME="$USERPROFILE/Downloads/dotfiles_downloads"
    [ -z "$DF_SOFTWARE_HOME" ] && export DF_SOFTWARE_HOME="$DF_HOME/opt"
    [ -z "$DF_APP_HOME" ] && export DF_APP_HOME="$DF_HOME/app"
    ;;
esac

DF_ARCH=
DF_ARCH_ARM_64="arm_64"
DF_ARCH_ARM_32="arm_32"
DF_ARCH_X86_64="x86_64"
DF_ARCH_X86_32="x86_32"

case "$(uname -m)" in
arm64 | aarch64 | armv8*)
    DF_ARCH="$DF_ARCH_ARM_64"
    ;;
armv7* | armv6*)
    DF_ARCH="$DF_ARCH_ARM_32"
    ;;
x86_64 | amd64)
    DF_ARCH="$DF_ARCH_X86_64"
    ;;
i*86)
    DF_ARCH="$DF_ARCH_X86_32"
    ;;
esac

[ ! -d "$DF_DOWNLOADS_HOME" ] && mkdir -p "$DF_DOWNLOADS_HOME"
[ ! -d "$DF_SOFTWARE_HOME" ] && mkdir -p "$DF_SOFTWARE_HOME"
