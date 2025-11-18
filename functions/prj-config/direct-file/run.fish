source $HOME/.config/fish/functions/prj-config/direct-file/info.fish

function run --description "$DESCRIPTION"
    cd $LOCATION
	echo -e "Project: $LONGNAME"
	echo -e "Location: $LOCATION"
	echo -e "Description: $DESCRIPTION"
	echo -e "Labels:"
	echo -e "\t$LABEL_1"
	echo -e "\t$LABEL_2"
	echo -e "\t$LABEL_3"
	echo -e "\t$LABEL_4"
	echo -e "\t$LABEL_5"
	echo -e "\t$LABEL_6"


    tmux new-session -d -c "$LOCATION" -s "$LONGNAME" -n "$LABEL_1" nvim Makefile
    tmux new-window -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_2" nvim "$LOCATION/source/api/eFileMadeEasy.DirectFile.API/eFileMadeEasy.DirectFile.API.sln"
    tmux new-window -c "$LOCATION/source/web/direct-file-web" -t "$LONGNAME" -n "$LABEL_3" nvim "$LOCATION/source/web/direct-file-web/package.json"
    tmux new-window -c "$HOME/org" -t "$LONGNAME" -n "$LABEL_4" nvim "$ORGFILE"
    tmux new-window -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_5" claude
    tmux new-window -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_6"
    tmux attach -t "$LONGNAME"
end
