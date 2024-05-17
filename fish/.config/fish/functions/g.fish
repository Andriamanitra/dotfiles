function g
    if string match --quiet -- "$argv" ""
        ls -a
        return
    else if string match --quiet -- "$argv" "-"
        cd -
        return
    end

    set target (g.rb $argv)
    if test $status -ne 0
        # g.rb exited with error (usually "not found")
        return
    else if test -z "$target"
        # empty response means nothing to do
        return
    end

    # directory
    if test -d "$target"
        cd "$target"
    # text file
    else if test -f "$target"; and string match --quiet --regex "text/|application/json" (file --dereference --brief --mime-type "$target")
        $EDITOR "$target"
    # other file that exists
    else if test -e "$target"
        file "$target"
    # we should never hit this if g.rb works as it should
    else
         echo "something very unexpected happened"
         return 1
    end
end
