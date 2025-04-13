if status is-interactive
    # Commands to run in interactive sessions can go here
end



# Function to change directory to ~/git/project_orion, open Makefile in nvim, and set alias -po
function project_orion
    cd ~/git/project_orion
    nvim Makefile
end

function project_orion_dir
    cd ~/git/project_orion
    lt
end

function fish_greeting
    pokeget 390 702
end

function edit_fish
    cd ~/.config/fisd/
    nvim 
end

function edit_nvim
    cd ~/.config/nvim/
    nvim 
end

function edit_starship
    nvim ~/.config/starship.toml
end
export PATH="$PATH:/usr/local/bin/nvim/bin"
export PATH="$PATH:/home/adamkali/.local/omnisharp"
export PATH="$PATH:/home/adamkali/.local/bin"
export PATH="$PATH:/home/adamkali/.dotnet/tools"
export PATH="$PATH:/home/adamkali/.local/bin"
export PATH="$PATH:/opt/mssql-tools18/bin"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export VISUAL="/home/linuxbrew/.linuxbrew/bin/nvim"
export EDITOR="/home/linuxbrew/.linuxbrew/bin/nvim"

set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT true

alias ~p="project_orion"
alias ~P="project_orion_dir"
alias ef="edit_fish"
alias en="edit_nvim"
alias es="edit_starship"
alias ls="exa --icons"
alias lt="exa -T --icons"
alias py="python3"
alias vi="nvim"
alias lz="lazygit"
alias osh="OmniSharp"
alias wezterm='flatpak run org.wezfurlong.wezterm'

fish_vi_key_bindings 

# Add Go binaries directory to PATH
set -gx PATH $PATH $HOME/go/bin
source (/home/adamkali/.cargo/bin/starship init fish --print-full-init | psub)
export PATH="$PATH:~/.local/bin/tailwindcss"

# netcoredbg
export PATH="$PATH:/usr/local"

zoxide init fish | source



# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# pnpm
set -gx PNPM_HOME "/home/adamkali/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end


# pyenv init
if command -v pyenv 1>/dev/null 2>&1
  pyenv init - | source
end

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
