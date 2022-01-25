# Disable default greeting ("Welcome to fish, the friendly interactive shell")
set fish_greeting

# Don't ask which man page if there are multiple matches,
# just pick the first matching one
set -Ux MAN_POSIXLY_CORRECT

# Add /home/$USER/bin to path
fish_add_path ~/bin

# Make micro (https://github.com/zyedidia/micro/) the default editor if it is installed
type -q micro && set -Ux EDITOR (which micro)

# If bat (https://github.com/sharkdp/bat/) is installed
if type -q bat

    # Use bat as a manpager (for syntax highlighting in man pages)
    set -Ux MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -Ux MANROFFOPT "-c" # get rid of extra formatting characters

    # replace "cat" with bat's plain mode (no decorations or paging)
    # NOTE: use ctrl+space instead of space to prevent abbreviation from expanding
    abbr -a cat bat -pp
end
