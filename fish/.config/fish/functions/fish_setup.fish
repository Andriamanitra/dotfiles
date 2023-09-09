function fish_setup --description "run once to setup env variables, aliases, etc"
    # Disable default greeting ("Welcome to fish, the friendly interactive shell")
    set --universal fish_greeting

    # Don't ask which man page if there are multiple matches,
    # just pick the first matching one
    set -Ux MAN_POSIXLY_CORRECT

    fish_add_path ~/Packages/cargo/bin
    fish_add_path ~/Packages/npm/bin
    fish_add_path ~/.local/bin
    fish_add_path ~/bin

    # Make micro (https://github.com/zyedidia/micro/) the default editor if it is installed
    type -q micro && set -Ux EDITOR (which micro)

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

    # Package installation locations
    # todo: maybe use .gemrc, .npmrc instead?
    set -Ux CARGO_PATH ~/Packages/cargo
    set -Ux RUSTUP_HOME ~/Packages/rustup
    set -Ux GEM_HOME ~/Packages/gem
    set -Ux GEM_PATH $GEM_HOME:/usr/lib64/ruby/gems/3.0.0
    set -Ux GEM_SPEC_CACHE ~/Packages/gem/spec_cache
    set -Ux GOPATH ~/Packages/go
    set -Ux JULIA_DEPOT_PATH ~/Packages/julia
    set -Ux GHCUP_USE_XDG_DIRS yes
    type -q npm && npm config set prefix ~/Packages/npm
    return 0
end
