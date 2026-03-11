function suspend-after --description 'Sleep for a bit and then suspend'
    argparse h/help -- $argv
    or return

    if set -q _flag_help
    or not set -q argv[1]
        echo "Usage: suspend-after DURATION"
        echo "Arguments:"
        echo "  DURATION"\t"Any time expression understood by numbat"
        return 0
    end

    set tstr (string join "+" $argv)
    if set seconds (numbat -e "($tstr -> s) / s" 2>/dev/null)
        echo "Waiting $seconds seconds..."
        sleep $seconds
        loginctl suspend
    else
        echo "Invalid time expression: '$tstr'"
    end
end
