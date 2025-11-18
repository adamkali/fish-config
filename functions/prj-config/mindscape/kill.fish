source $HOME/.config/fish/functions/prj-config/mindscape/info.fish
function kill
	if tmux ls | grep -q $LONGNAME
		tmux kill-session -t $LONGNAME
	end
end
