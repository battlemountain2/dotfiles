# ~/.config/fish/functions/fish_prompt.fish
# Clean, single-line prompt: directory only (e.g. ~ ), no chevrons.

function fish_prompt
    set -l last_status $status

    if test $last_status -ne 0
        set_color ff7b72
    else
        set_color 94cdf6
    end

    echo -n (prompt_pwd)
    set_color normal

    # Show git branch when in a repository
    fish_vcs_prompt

    echo -n " "
end
