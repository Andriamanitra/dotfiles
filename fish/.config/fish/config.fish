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
    # enable fzf key bindings
    fzf_key_bindings
end
