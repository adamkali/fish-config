# org-edit is a function that will do the following:
# 1. load list from  ./literate-configs
# 2. load the array into fzf
# 3. when chosen use the chosen file to open in nvim
function norg --description "Open norg file in nvim"
	#--help "Open norg file in nvim"
	set -l lines (cat $HOME/.config/fish/functions/literate-configs | string split \n)
	
	# Extract display names for fzf
	set -l display_names
	for line in $lines
		if test -n "$line"
			set -l name (string split '|' "$line")[1]
			set -a display_names "$name"
		end
	end
	
	# Show display names in fzf
	set -l chosen_name (printf "%s\n" $display_names | fzf)
	
	if test -n "$chosen_name"
		# Find the corresponding path
		for line in $lines
			if test -n "$line"
				set -l parts (string split '|' "$line")
				if test "$parts[1]" = "$chosen_name"
					set -l expanded_path (string replace '$HOME' $HOME "$parts[2]")
					nvim "$expanded_path"
					break
				end
			end
		end
	end
end
