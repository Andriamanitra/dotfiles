_default:
    @just -l

setup-cli:
    stow -t $HOME git
    stow -t $HOME fish
    stow -t $HOME micro
    stow -t $HOME nano
    stow -t $HOME gdb
    stow -t $HOME ranger
    fish -c fish_setup
