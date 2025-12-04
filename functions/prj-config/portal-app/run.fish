source $HOME/.config/fish/functions/prj-config/portal-app/info.fish

function run --description "$DESCRIPTION"
    cd $LOCATION
	echo -e "Project: $LONGNAME"
	echo -e "Location: $LOCATION"
	echo -e "Description: $DESCRIPTION"

    tmux new-session -d -c "$LOCATION"       -s "$LONGNAME" -n "$LABEL_1" $EDITOR
	tmux new-window  -c    "$LOCATION"       -t "$LONGNAME" -n "$LABEL_2" $ACTION_2
	tmux new-window  -c    "$LOCATION"       -t "$LONGNAME" -n "$LABEL_3" fish
	tmux new-window  -c    "$LOCATION"       -t "$LONGNAME" -n "$LABEL_4" yarn start:dev
	tmux new-window  -c    "$LOCATION_NOTES" -t "$LONGNAME" -n "$LABEL_5" $EDITOR
    tmux attach      -t    "$LONGNAME"
end
