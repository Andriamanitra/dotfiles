# Disable default greeting ("Welcome to fish, the friendly interactive shell")
set fish_greeting

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
    alias cat="bat -pp"
end

# If btop is installed
if type -q btop
    alias top="btop"
end

# Package installation locations
# todo: maybe use .gemrc, .npmrc instead?
set -Ux CARGO_PATH ~/Packages/cargo
set -Ux GEM_HOME ~/Packages/gem
set -Ux GEM_PATH $GEM_HOME:/usr/lib64/ruby/gems/3.0.0
set -Ux GEM_SPEC_CACHE ~/Packages/gem/spec_cache
set -Ux GOPATH ~/Packages/go
set -Ux JULIA_DEPOT_PATH ~/Packages/julia
type -q npm && npm config set prefix ~/Packages/npm

# enable fzf key bindings
type -q fzf && fzf_key_bindings

# key bindings:
# !! = last command from history
# head! = first token of the last command from history
# last! = last token of the last command from history
# init! = all but last token of the last commmand from history
# tail! = all but first token of the last command from history
function bind_bang --description "shortcuts using !"
    set tok (commandline --current-token)[-1]
    switch $tok
        case "!"
            commandline --current-token -- $history[1]
            commandline --function repaint
        case "first" "head"
            echo $history[1] | read --local --list --tokenize last_cmd
            commandline --current-token -- $last_cmd[1]
            commandline --function repaint
        case "last"
            echo $history[1] | read --local --list --tokenize last_cmd
            commandline --current-token -- $last_cmd[-1]
            commandline --function repaint
        case "init"
            echo $history[1] | read --local --list --tokenize last_cmd
            commandline --current-token -- "$last_cmd[1..-2]"
            commandline --function repaint
        case "rest" "tail"
            echo $history[1] | read --local --list --tokenize last_cmd
            commandline --current-token -- "$last_cmd[2..-1]"
            commandline --function repaint
        case "*"
            commandline --insert !
    end
end


function fish_user_key_bindings
    bind ! bind_bang
end
