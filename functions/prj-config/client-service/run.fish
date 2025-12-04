source $HOME/.config/fish/functions/prj-config/client-service/info.fish

function run --description "$DESCRIPTION"
    cd $LOCATION
    tmux new-session -d -c "$LOCATION" -s "$LONGNAME" -n "$LABEL_1" $ACTION_1
	tmux new-window     -c "$HOME/org" -t "$LONGNAME" -n "$LABEL_2" $ACTION_2
	tmux new-window     -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_3" $ACTION_3
	tmux new-window     -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_4" $ACTION_4
	tmux new-window     -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_5" $ACTION_5
	tmux new-window     -c "$LOCATION" -t "$LONGNAME" -n "$LABEL_6" $ACTION_6
    tmux attach         -t "$LONGNAME"
end
