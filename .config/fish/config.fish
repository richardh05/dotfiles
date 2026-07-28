if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting
#set -U fish_greeting "🐟"

# == ABBREVIATIONS ==
abbr vi "nvim"
abbr vim "nvim"
abbr la "ls -a"
abbr s "sudo"
abbr p "sudo pacman"
abbr spt "spotify_player"
#abbr stowdots "stow -d ~/dots/home -t ~/ ."
abbr neofetch "fastfetch"
abbr newsboat "newsboat -u ~/Documents/urls"
abbr i3conf "nvim ~/.config/i3/config"
abbr kittyconf "nvim .config/kitty/kitty.conf"
abbr fishconf "nvim .config/fish/config.fish"
abbr executable "chmod +x"
set -gx PATH "$HOME/Scripts:$HOME/.local/share/JetBrains/Toolbox/scripts:$HOME/.local/share/dotnet:$HOME/.local/bin:$PATH:/opt/dotnet/cli/.dotnet/tools"

if test -f ~/.profile
    # Use 'declare -p' to get a scriptable output of variables from a Bash subshell.
    # The grep commands filter out problematic variables that cause errors in Fish.
    set --local profile_vars (bash -c 'source ~/.profile; declare -p' | grep -E '^declare --' | grep -vE '^declare -- (BASH|COMP|DIRSTACK|EPOCH|EUID|FUNCNAME|GROUPS|HOME|HOSTNAME|HOSTTYPE|IFS|LANG|LC|LINENO|MACHTYPE|MAILCHECK|OLDPWD|OPTERR|OPTIND|OSTYPE|PATH|PIPESTATUS|PPID|PROMPT_COMMAND|PS1|PS2|PS3|PS4|PWD|RANDOM|SECONDS|SHELL|SHLVL|TERM|TMOUT|UID|_)')

    for line in $profile_vars
        # Use string replace to get the key and value
        set --local key (string replace -r '^declare --x? ([^=]+)=.*' '$1' "$line")
        set --local key (string replace -r '^declare -- ([^=]+)=.*' '$1' "$line")
        set --local value (string replace -r '^declare --x? [^=]+="(.*)"$' '$1' "$line")
        set --local value (string replace -r '^declare -- [^=]+="(.*)"$' '$1' "$line")

        # Set and export the variable in Fish
        if not string match -q '_=' "$line"
            set -gx "$key" "$value"
        end
    end
end
#wants to be at the end
source ~/.config/fish/functions/zoxide.fish
