# Dotfiles

Just some configuration files for safe-keeping. Nothing special going on here.

Intended to be used with GNU Stow.
For example, to symlink files from git/ directory run `stow git` (will not overwrite anything if files already exist).

Instead of typing all the stow commands manually you can run `just setup-cli` to quickly get all the command line tool configs set up (good for use on servers or docker or qemu or whatever).


## Essential packages

Arch repos should have all of these, other distros are probably missing some...

* fish (shell)
* micro (terminal-based text editor)
* terminator (terminal emulator)
* tealdeer (tldr pages)
* stow (for dotfiles)
* just (command runner)
* ranger (terminal based file system navigation)
* julia (programming language for more complicated calculations)
* fd (better than find)
* fzf (fuzzy search)
* jq (json querying & formatting)
* qalculate (superb calculator with unit support)
* bpython (nicer python interpreter)

### LESSONS LEARNED:

* forget about texlive and just use [typst](https://github.com/typst/typst) or [tectonic](https://github.com/tectonic-typesetting/tectonic/) for typesetting
* do **NOT** install ghc or julia or rust directly – use ghcup, juliaup and rustup to manage the installations instead
