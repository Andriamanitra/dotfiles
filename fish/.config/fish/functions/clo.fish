function clo --wraps='git clone' --description 'git clone && cd'
    git clone $argv
    if test $status -eq 0
        if string match -q --regex '^(gh:|https?:|git@)' "$argv[-1]"
            set giturl (string replace --regex '\.git$' '' "$argv[-1]")
            set directory (string split "/" "$giturl")[-1]
        else
            set directory "$argv[-1]"
        end
        cd $directory
    end
end
