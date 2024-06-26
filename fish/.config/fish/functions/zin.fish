# A fish function that uses fzf and zypper (OpenSUSE's package manager) to
# browse packages.

# In order to avoid the latency from running "zypper search", this function
# relies on ~/.zinpackages file that contains information about packages. You
# can generate one for yourself by running this command (you probably want to
# do it in a cronjob to keep the file up to date):

#~> zypper search | tail -n+6 > $XDG_CACHE_HOME/zin/packages

# Or you could write a fancier script to include whatever package information
# you want in $XDG_CACHE_HOME/zin/packages!

function zin --description 'Usage: zin [PACKAGE SEARCH QUERY]'
    if set -q XDG_CACHE_HOME; and test -n $XDG_CACHE_HOME
      set -f packages_file "$XDG_CACHE_HOME/zin/packages"
    else
      set -f packages_file "$HOME/.cache/zin/packages"
    end

    # cut makes sure the lines are never too long for the current terminal width
    set -f pkgs_to_install (\
        cut -c-$COLUMNS $packages_file \
        | fzf -q "$argv" -m --tac --tiebreak=begin --exact --delimiter "\|" \
              --preview-window=up,12 --preview 'zypper info {2} | sed -e 1,/---------------/d' \
        | cut -d "|" -f2 \
        | xargs)
    # if $pkgs_to_install is not empty (fzf was not cancelled), install selected packages
    if test -n $pkgs_to_install
        echo
        echo "EXECUTING: sudo zypper install $pkgs_to_install"
        echo
        sudo zypper install (string split ' ' $pkgs_to_install)
    end
end
