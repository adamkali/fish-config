source $HOME/.config/fish/functions/prj-config/client-service/info.fish
function kill
	if tmux ls | grep -q $LONGNAME
		tmux kill-session -t $LONGNAME
	end
end
