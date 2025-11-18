source $HOME/.config/fish/functions/prj-config/{+basename+}/info.fish

function run --description "$DESCRIPTION"
    cd $LOCATION
	echo -e "Project: $LONGNAME"
	echo -e "Location: $LOCATION"
	echo -e "Description: $DESCRIPTION"
	echo -e "Labels:"
	echo -e "\t$LABEL_1"


    tmux new-session -d -c "$LOCATION" -s "$LONGNAME" -n "$LABEL_1" nvim Makefile
	# uncomment if you want more windows and whatnot
	# tmux new-window -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_2" nvim "$LOCATION/source/api/eFileMadeEasy.DirectFile.API/eFileMadeEasy.DirectFile.API.sln"
    tmux attach -t "$LONGNAME"
end
