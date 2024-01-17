function fish_setup --description "run once to setup env variables, aliases, etc"
    # Disable default greeting ("Welcome to fish, the friendly interactive shell")
    set --universal fish_greeting

    set -Ux XDG_CONFIG_HOME $HOME/.config
    set -Ux XDG_CACHE_HOME $HOME/.cache
    set -Ux XDG_DATA_HOME $HOME/.local/share
    set -Ux XDG_STATE_HOME $HOME/.local/state

    # Don't ask which man page if there are multiple matches,
    # just pick the first matching one
    set -Ux MAN_POSIXLY_CORRECT

    fish_add_path ~/Packages/cargo/bin
    fish_add_path ~/Packages/npm/bin
    fish_add_path ~/.local/bin
    fish_add_path ~/bin

    # Make micro (https://github.com/zyedidia/micro/) the default editor if it is installed
    type -q micro && set -Ux EDITOR (which micro)

    if type -q fd
        set -Ux FZF_DEFAULT_COMMAND "fd --type file --hidden --follow"
        set -Ux FZF_CTRL_T_COMMAND "fd --type file --hidden --follow"
        set -Ux FZF_ALT_C_COMMAND "fd . --type directory --no-ignore-vcs --hidden --follow"
    end

    # If bat (https://github.com/sharkdp/bat/) is installed
    if type -q bat

        # Use bat as a manpager (for syntax highlighting in man pages)
        set -Ux MANPAGER "sh -c \"col -bx | bat -l man -p\""
        set -Ux MANROFFOPT "-c" # get rid of extra formatting characters

        # replace "cat" with bat's plain mode (no decorations or paging)
        # NOTE: use ctrl+space instead of space to prevent abbreviation from expanding
        alias --save cat="bat -pp"
    else
        functions -e cat
    end

    # If btop is installed
    if type -q btop
        alias --save top="btop"
    else
        functions -e top
    end

    # If ruff is installed
    if type -q ruff
        ruff generate-shell-completion fish > $XDG_CONFIG_HOME/fish/completions/ruff.fish
    end

    # If just is installed
    if type -q just
        just --completions fish > $XDG_CONFIG_HOME/fish/completions/just.fish
    end

    if type -q delta
        set -Ux GIT_PAGER "delta"
    end

    # Package installation locations
    # todo: maybe use .gemrc, .npmrc instead?
    set -Ux CARGO_PATH ~/Packages/cargo
    set -Ux RUSTUP_HOME ~/Packages/rustup
    set -Ux GEM_HOME ~/Packages/gem
    set -Ux GEM_PATH $GEM_HOME:/usr/lib64/ruby/gems/3.0.0
    set -Ux GEM_SPEC_CACHE ~/Packages/gem/spec_cache
    set -Ux GOPATH ~/Packages/go
    set -Ux JULIA_DEPOT_PATH ~/Packages/julia
    set -Ux JULIAUP_DEPOT_PATH ~/Packages/julia
    type -q npm && npm config set prefix ~/Packages/npm

    set -Ux GHCUP_USE_XDG_DIRS yes

    set -Ux WINEPREFIX $XDG_DATA_HOME/wine

    set -Ux CUDA_CACHE_PATH $XDG_CACHE_HOME/nv

    set -Ux DOCKER_CONFIG $XDG_CONFIG_HOME/docker

    # i don't think these environment variables for bundler are documented but they
    # are found in ruby source code:
    # https://github.com/ruby/ruby/blob/b635a66e957e4dd3fed83ef1d72ce8c9b57e0430/lib/bundler.rb#L263
    set -Ux BUNDLE_USER_HOME $XDG_CONFIG_HOME/bundle
    set -Ux BUNDLE_USER_CACHE $XDG_CACHE_HOME/bundle

    set -Ux INPUTRC $XDG_CONFIG_HOME/readline/inputrc

    set -Ux RLWRAP_HOME ~/.history
    set -Ux HISTFILE ~/.history/bash_history
    set -Ux SQLITE_HISTORY ~/.history/sqlite_history
    set -Ux NODE_REPL_HISTORY ~/.history/node_history
    return 0
end
