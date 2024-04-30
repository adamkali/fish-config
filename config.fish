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
    nvim ~/.config/fish/config.fish
end

function edit_nvim
    nvim ~/.config/nvim/init.lua
end

function edit_starship
    nvim ~/.config/starship.toml
end

alias ~p="project_orion"
alias ~P="project_orion_dir"
alias ef="edit_fish"
alias en="edit_nvim"
alias es="edit_starship"
alias ls="exa --icons"
alias lt="exa -T --icons"
alias py="python3"


export PATH="$PATH:/opt/nvim-linux64/bin"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

fish_vi_key_bindings 

# Add Go binaries directory to PATH
set -gx PATH $PATH $HOME/go/bin
source (/home/adamkali/.cargo/bin/starship init fish --print-full-init | psub)

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
