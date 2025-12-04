# Adam Kalinowski's Fish config 

#    ___________.__       .__      _________                _____.__        
#   \_   _____/|__| _____|  |__   \_   ___ \  ____   _____/ ____\__| ____  
#    |    __)  |  |/  ___/  |  \  /    \  \/ /  _ \ /    \   __\|  |/ ___\ 
#    |     \   |  |\___ \|   Y  \ \     \___(  <_> )   |  \  |  |  / /_/  >
#    \___  /   |__/____  >___|  /  \______  /\____/|___|  /__|  |__\___  / 
#        \/            \/     \/          \/            \/        /_____/

# Interactive session

if status is-interactive
# Commands to run in interactive sessions can go here
end

# Change to the current project Directory

function  change_to_project
cd ~/projects/mindscape/
end

# Fish Geeting 

function fish_greeting
pokeget 390 702
end

# Source important variables

export PATH="$PATH:/usr/local/bin/nvim/bin"
export PATH="$PATH:/home/adamkali/.dotnet/tools"
export PATH="$PATH:/home/adamkali/.local/bin"
export PATH="$PATH:/opt/mssql-tools18/bin"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export VISUAL="/home/linuxbrew/.linuxbrew/bin/nvim"
export EDITOR="/home/linuxbrew/.linuxbrew/bin/nvim"
export DOOMDIR=$HOME/.config/doom/

set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT true

alias ls="exa --icons"
alias lt="exa -T --icons"
alias py="python3"
alias vi="nvim"
alias lz="lazygit"
alias ld="lazydocker"
alias osh="OmniSharp"
alias wezterm='flatpak run org.wezfurlong.wezterm'
alias ff="pokeget infernape --hide-name | fastfetch --file-raw -"
alias fzm="fzf-make"

# Vim Keybindings

fish_vi_key_bindings 

# Add Go binaries directory to PATH

set -gx PATH $PATH $HOME/go/bin

# Init starship

source (/home/adamkali/.cargo/bin/starship init fish --print-full-init | psub)

# Add TailwindCSS to the path

export PATH="$PATH:~/.local/bin/tailwindcss"

# Add Netcoredbg to the path 

export PATH="$PATH:/usr/local"

# Configure Bun and add it to the path

set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Install and Configure pnpm

set -gx PNPM_HOME "/home/adamkali/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
set -gx PATH "$PNPM_HOME" $PATH
end

# Configure ghcup

set -q GHcup_INSTALL_BASE_PREFIX[1]; or set GHcup_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin $PATH /home/adamkali/.ghcup/bin # ghcup-env

# Configure brew

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Configure zoxide and source it 

zoxide init fish | source

# Set up fzf with some customizations via environment variables 

fzf --fish | source
set --export FZF_COMPLETION_TRIGGER '~~'
set --export FZF_COMPLETION_OPTS '--border --info=inline'
set --export FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git,node_modules --color=always'
set --export FZF_COMPLETION_PATH_OPTS '--walker file,dir,follow,hidden'

# Add in Git integrations into fznf

source ~/fzf-git.sh/fzf-git.fish

# Configure bat

set --export BAT_THEME "Vaporlush"
set --export BAT_STYLE "numbers,grid"

# Configure nvim to be the Manager

set --export MANPAGER "nvim +Man!"