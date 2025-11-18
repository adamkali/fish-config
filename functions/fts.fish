# Fuzzy Find SSH Tailscale Hosts and SSH into it

# FTS: fzf Tailscale ssh
#     : Connect to a computer of you choice using tailscale network.
#     : Allows for easy SSH access and no need to do authentication manually

function fts -d "Connect to a cumputer using tailscale network. Allows for easy SSH access and no need to do authentication manually"
    set -l Hosts $(tailscale status | awk '{if ($0 == "") exit; print $2}')
    echo $Hosts | tr ' ' '\n' | fzf --height 40% --layout=reverse --border --preview="tailscale ping {} | awk '{print $3 $8}'" --preview-window=right:65%  | read -l result
    echo "  Please enter Login User for ssh: "
    read -l username
    ssh -l "$username" "$result"
end
