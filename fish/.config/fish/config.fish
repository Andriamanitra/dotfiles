tabs -4  # set tab stops to 4, 8, 12, ...

# abbr
abbr -a -- j just
abbr -a -- x xdg-open
abbr -a -- drun 'docker run --rm -it'
abbr -a -- vvenv 'test -d venv || python3 -m virtualenv venv && . venv/bin/activate.fish'
abbr -a -- bpast 'curl https://bpa.st/curl -F "raw=<-"'
abbr -a -- pasters 'curl -X POST https://paste.rs --data-binary @-'

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
    functions -q fzf_key_bindings && fzf_key_bindings
end
