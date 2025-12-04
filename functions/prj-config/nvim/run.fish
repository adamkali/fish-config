source $HOME/.config/fish/functions/prj-config/nvim/info.fish

function run --description "$DESCRIPTION"
    cd $LOCATION
	echo -e "Project: $LONGNAME"
	echo -e "Location: $LOCATION"
	echo -e "Description: $DESCRIPTION"
	echo -e "Labels:"


    tmux new-session -d -c "$LOCATION_NEOVIM" -s "$LONGNAME" -n "$LABEL_1" $ACTION_1
	tmux new-window -c "$LOCATION_LITERATE_CONFIG" -t "$LONGNAME" -n "$LABEL_2" $ACTION_2
	tmux new-window -c "$LOCATION_VS_PLUGIN" -t "$LONGNAME" -n "$LABEL_3" $ACTION_3
	tmux new-window -c "$LOCATION_NEOVIM" -t "$LONGNAME" -n "$LABEL_4" $ACTION_4
	tmux new-window -c "$LOCATION_NEOVIM" -t "$LONGNAME" -n "$LABEL_5" $ACTION_5
	# uncomment if you want more windows and whatnot
	# tmux new-window -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_2" nvim "$LOCATION/source/api/eFileMadeEasy.DirectFile.API/eFileMadeEasy.DirectFile.API.sln"
    tmux attach -t "$LONGNAME"
end
