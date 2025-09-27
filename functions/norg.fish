# org-edit is a function that will do the following:
# 1. load list from  ./literate-configs
# 2. load the array into fzf
# 3. when chosen use the chosen file to open in nvim
function norg --description "Open norg file in nvim"
	--help "Open norg file in nvim"
	set -l configs (cat $HOME/.config/fish/functions/literate-configs)
	set -l chosen (string split , $configs | fzf)
	nvim $chosen
end
