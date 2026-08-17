# ~/.config/fish/config.fish
#
# Self-contained. Deliberately does NOT source
# /usr/share/cachyos-fish-config/cachyos-config.fish, which is pacman-owned
# and can change under you on -Syu. The one exception is the `done` plugin,
# sourced by path near the bottom.

# ─── PATH ─────────────────────────────────────────────────────────────────
#
# -g, not the default -U. Universal vars get written to ~/.config/fish/
# fish_variables and persist forever; -g rebuilds PATH from this file every
# session, so this file is the only source of truth. Note that fish_add_path
# silently skips directories that don't exist yet, and re-checks each startup.

fish_add_path -g ~/.local/bin
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.spicetify
fish_add_path -g ~/Applications/depot_tools

# ─── Environment ──────────────────────────────────────────────────────────

if type -q bat
    set -gx MANROFFOPT -c
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

# kate needs -b (--block), or it forks immediately and git sees an unchanged
# message file and aborts the commit. Matches EDITOR in hypr variables.lua.
set -gx EDITOR "kate -b"

# ─── Functions ────────────────────────────────────────────────────────────
#
# Defined unconditionally so fish scripts can use them too. Defining a
# function is just parsing; it costs effectively nothing at startup.

function fish_greeting
    type -q fastfetch; and fastfetch
end

function backup -a filename -d "Copy FILE to FILE.bak"
    if test -z "$filename"
        echo "usage: backup FILE" >&2
        return 1
    end
    command cp -r -- $filename $filename.bak
end

function copy -d "cp, but `copy DIR1 DIR2` copies DIR1 itself, not its contents"
    if test (count $argv) -eq 2; and test -d "$argv[1]"
        # The stock version pipes through `trim-right`, which is not a real
        # binary on CachyOS — it's inherited from Garuda's config and was
        # never packaged. Check with `type trim-right`; if that comes back
        # empty, this branch has never worked. `string trim` is the native fix.
        command cp -r (string trim -r -c / -- $argv[1]) $argv[2]
    else
        command cp $argv
    end
end

function history -d "history, with timestamps"
    # --show-time only applies to the search/list forms; passing it to the
    # mutating subcommands is an error, so `history delete foo` breaks under
    # the stock config. This routes those through untouched.
    switch "$argv[1]"
        case delete clear clear-session merge save append
            builtin history $argv
        case '*'
            builtin history --show-time='%F %T ' $argv
    end
end

function cleanup -d "Remove orphaned packages"
    if not type -q pacman
        echo "cleanup: pacman not found" >&2
        return 1
    end
    # `pacman -Rns` with zero args is an error — which is what the stock alias
    # does every time there's nothing to clean.
    set -l orphans (pacman -Qtdq)
    if test -z "$orphans"
        echo "No orphaned packages."
        return 0
    end
    sudo pacman -Rns $orphans
end
# ─── Key bindings: !! and !$ ──────────────────────────────────────────────
#
# fish calls fish_user_key_bindings during interactive startup, after this
# file is read. Defining it here (rather than binding loose at top level, as
# the stock config does) means these survive a runtime switch to
# fish_vi_key_bindings, which would otherwise wipe them.

function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    if test "$fish_key_bindings" = fish_vi_key_bindings
        bind -M insert ! __history_previous_command
        bind -M insert '$' __history_previous_command_arguments
    else
        bind ! __history_previous_command
        bind '$' __history_previous_command_arguments
    end
end

# ─── done ─────────────────────────────────────────────────────────────────
#
# Notifies when a long command finishes in a terminal you aren't looking at.
# CachyOS ships it inside its config package rather than standalone.
#
# These are -g, not the stock -U: done.fish only assigns its own defaults
# behind `set -q`, so a global set here wins and nothing gets written to
# fish_variables on every startup.
#
# done.fish self-guards with `if not status is-interactive; exit; end`, and
# fish scopes that `exit` to the sourced block — so it will NOT kill your
# non-interactive shells or fish scripts. No guard needed on this end.

set -g __done_min_cmd_duration 10000
set -g __done_notification_urgency_level low
set -g __done_notification_urgency_level_failure normal  # else failures force `critical`
set -g __done_exclude '^git (?!push|pull|fetch)' '^nvim' '^ssh'

set -l done_path /usr/share/cachyos-fish-config/conf.d/done.fish
test -f $done_path; and source $done_path

# ─── Interactive only ─────────────────────────────────────────────────────

status is-interactive; or exit

# Abbreviations expand inline before you hit enter, so you see the real
# command in the prompt. Worth the two keystrokes for anything with sudo.

abbr -a ..     'cd ..'
abbr -a ...    'cd ../..'
abbr -a ....   'cd ../../..'
abbr -a .....  'cd ../../../..'
abbr -a ...... 'cd ../../../../..'

# No trailing space on these — fish abbrs aren't bash aliases, and the
# trailing space in the stock config does nothing here.
abbr -a tarnow 'tar -acf'
abbr -a untar  'tar -zxvf'

abbr -a psmem   'ps auxf | sort -nr -k 4'
abbr -a psmem10 'ps auxf | sort -nr -k 4 | head -10'

if type -q pacman
    abbr -a update    'sudo cachyos-rate-mirrors && sudo pacman -Syu'
    abbr -a mirror    'sudo cachyos-rate-mirrors'
    abbr -a grubup    'sudo grub-mkconfig -o /boot/grub/grub.cfg'
    abbr -a fixpacman 'sudo rm /var/lib/pacman/db.lck'
    abbr -a jctl      'journalctl -p 3 -xb'
    abbr -a gitpkg    'pacman -Q | grep -i "\-git" | wc -l'
end

if type -q expac
    abbr -a big 'expac -H M "%m\t%n" | sort -h | nl'
    abbr -a rip 'expac --timefmt="%Y-%m-%d %T" "%l\t%n %v" | sort | tail -200 | nl'
end

type -q hwinfo; and abbr -a hw 'hwinfo --short'

# Aliases: things you never need to review before running.

if type -q eza
    alias ls 'eza -al --color=always --group-directories-first --icons=always'
    alias la 'eza -a  --color=always --group-directories-first --icons=always'
    alias ll 'eza -l  --color=always --group-directories-first --icons=always'
    alias lt 'eza -aT --color=always --group-directories-first --icons=always'
    alias l. 'eza -ad --color=always --icons=always .*'
end

alias grep  'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'
alias dir   'dir --color=auto'
alias vdir  'vdir --color=auto'

alias wget 'wget -c'
alias tb   'nc termbin.com 9999'
