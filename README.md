# Dotfiles

Just some configuration files for safe-keeping. Nothing special going on here.

Intended to be used with GNU Stow.
For example, to symlink files from git/ directory run `stow git` (will not overwrite anything if files already exist).


## Essential packages

Arch repos should have all of these, other distros are probably missing some...

* fish (shell)
* micro (terminal-based text editor)
* terminator (terminal emulator)
* tealdeer (tldr pages)
* stow (for dotfiles)
* ranger (terminal based file system navigation)
* julia (programming language for more complicated calculations)
* fd (better than find)
* fzf (fuzzy search)
* jq (json querying & formatting)
* qalculate (superb calculator with unit support)
* bpython (nicer python interpreter)

### LESSONS LEARNED:

* Arch & friends:
  - if there are problems with installing/using Pkgs in julia, try julia-bin from AUR
  - for LaTeX, `pacman -Syu texlive-most` (do **NOT** touch `texlive-full` from AUR) to install everything at once, otherwise you'll go insane
