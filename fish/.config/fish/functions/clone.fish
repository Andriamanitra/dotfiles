function clone
    git clone $argv[1..-2] git@github.com:$argv[-1]
end
