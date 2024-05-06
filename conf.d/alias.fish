# Function to change directory to ~/git/project_orion, open Makefile in nvim, and set alias -po
function project_orion
    cd ~/git/project_orion
    nvim Makefile
end

function project_orion_dir
    cd ~/git/project_orion
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

function update_and_upgrade_no_confirm
    sudo apt-get update -y
    sudo apt-get upgrade -y
end

alias ~p="project_orion"
alias ~P="project_orion_dir"
alias ef="edit_fish"
alias en="edit_nvim"
alias es="edit_starship"
alias ls="exa --icons"
alias lt="exa -T --icons"
alias py="python3"
alias nv="nvim"
alias mkd="mkdir -p"
alias rmf="rm -rf"
alias ~~="cd ~/git"
alias lol="lolcat"
alias suu="update_and_upgrade_no_confirm"


