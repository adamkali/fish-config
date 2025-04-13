# Function to change directory to ~/git/project_orion, open Makefile in nvim, and set alias -po
function project_orion
    cd ~/git/project_orion
    nvim Makefile
end

function project_orion_dir
    cd ~/git/project_orion
end

function edit_fish
    cd ~/.config/fish/
    nvim config.fish
end

function edit_nvim
    cd ~/.config/nvim/
    nvim init.lua
end

function edit_starship
    nvim ~/.config/starship.toml
end

function update_and_upgrade_no_confirm
    sudo apt-get update -y
    sudo apt-get upgrade -y
end

function cd_pyportal
    cd /mnt/c/s/e/PyPortalWorkflow
    nvim
end

function filing_portal
    cd ~/efme/FilingPortal/app/
    nvim Makefile
end

function client_service
    cd ~/efme/ClientService/eFileMadeEasy.Client
    nvim Makefile
end

alias ~g="cd ~/git"
alias ~e="cd ~/efme"
alias ~c="cd ~/.config"
alias ~p="project_orion"
alias ~P="project_orion_dir"
alias efpy="cd_pyportal"
alias ef="edit_fish"
alias en="edit_nvim"
alias es="edit_starship"
alias c="z"
alias ci="zi"
alias ls="exa --icons"
alias lt="exa -T --icons"
alias py="python3"
alias nv="nvim"
alias mkd="mkdir -p"
alias rmf="rm -rf"
alias lol="lolcat"
alias suu="update_and_upgrade_no_confirm"
alias sai="sudo apt install"

alias Ef=filing_portal
alias Ecs=client_service

alias ld="lazydocker"
alias lg="lazygit"
alias lds="DOCKER_HOST='ssh://kalilarosa@kalilarosa.xyz' lazydocker"


alias lsp='lsof -i -P | grep'
