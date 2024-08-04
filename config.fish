if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_greeting
    pokeget 390 702
end

export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/home/adamkali/.dotnet/tools"
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin

fish_vi_key_bindings 
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Add Go binaries directory to PATH
set -gx PATH $PATH $HOME/go/bin
source (/home/adamkali/.cargo/bin/starship init fish --print-full-init | psub)
export PATH="$PATH:~/.local/bin/tailwindcss"

# netcoredbg
export PATH="$PATH:/home/adamkali/tarballs/netcoredbg"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
export NVM_DIR="$HOME/.nvm"

# pnpm
set -gx PNPM_HOME "/home/adamkali/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
