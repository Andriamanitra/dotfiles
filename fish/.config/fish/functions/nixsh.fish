function nixsh --wraps="nix shell"
    PRE_PROMPT="$PRE_PROMPT(nixsh) " nix shell $argv
end
