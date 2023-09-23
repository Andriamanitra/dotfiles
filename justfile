_default:
    @just -l

setup-cli:
    # if we make sure these directories exist before running `stow`
    # some extra garbage will live in (for example)
    #   $HOME/.config/sublime-text/Log
    # instead of
    #   $HOME/dotfiles/sublime/.config/sublime-text/Log
    # so there's less garbage to .gitignore
    mkdir -p $HOME/.config/sublime-text
    mkdir -p $HOME/.config/micro
    mkdir -p $HOME/.config/fish/conf.d
    mkdir -p $HOME/.config/fish/completions

    stow -t $HOME git
    stow -t $HOME fish
    stow -t $HOME micro
    stow -t $HOME nano
    stow -t $HOME gdb
    stow -t $HOME ranger
    fish -c fish_setup
