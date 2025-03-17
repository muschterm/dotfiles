# dotfiles

Repository that includes helpful terminal setup scripts.

### TL;DR

- `install-*sh`
  - A script that sets up a user's `zsh` or `bash` login shell to initialize the `init` script.
- `init.sh`
  - Sets up the terminal shell with useful scripts and installs software is specified.
  - Ensure that `helper-functions` is loaded into the current shell to allow use of easier printing and formatting functions.

## User Shell

Using the `install-*sh` script will set up the user's shell to leverage the `init` script.

Both `zsh` and `bash` are supported - `zsh` being the preferred script.

### Default Configurations

#### Linux

...

#### Mac OS

- Forces the user to install `Homebrew` in order to leverage the standard GNU coreutils binaries along with several others.

#### Windows

- If using _WSL_, the experience will not differ much from _Linux_ as software, etc. will assume to be _Linux_ rather than _Windows_ specific.
- If using _Cygwin_ or _MINGW_, there are certain assumptions to use _Windows_ binaries for software.

## Docker Images

A `Dockerfile` should:

- copy the `init` script to `/etc/profile.d/init.sh`,
- copy the `/bin/helper-functions` script to `/usr/bin/`, and
- copy the `/bin/trap-errors` script to `/usr/bin/`.

This will make a cleaner login shell, along with utility functions, that should be compatible with most default shells (`sh`, `ash`, `dash`, `bash`, etc.).
