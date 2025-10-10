_default:
    @just -l

setup-cli:
    stow --no-folding -t $HOME git
    stow --no-folding -t $HOME fish
    stow --no-folding -t $HOME micro
    stow --no-folding -t $HOME nano
    stow --no-folding -t $HOME gdb
    stow --no-folding -t $HOME yazi
    fish -c fish_setup
