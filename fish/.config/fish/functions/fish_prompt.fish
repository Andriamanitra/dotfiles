function fish_prompt --description 'Write out the prompt'
    set_color cyan
    if set -q PRE_PROMPT
        echo -n -s "$PRE_PROMPT"
    end
    set_color normal

    switch "$USER"
        case root toor
            echo -n -s "$USER" @ (prompt_hostname) ' ' (set -q fish_color_cwd_root
                                                        and set_color $fish_color_cwd_root
                                                        or set_color $fish_color_cwd) (prompt_pwd) \
                (set_color normal) '# '

        case '*'
            echo -n -s "$USER" @ (prompt_hostname) ' ' (set_color $fish_color_cwd) (prompt_pwd) \
                (set_color normal) '> '

    end
end
