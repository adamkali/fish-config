source $HOME/.config/fish/functions/prj-config/mindscape/info.fish

function run --description "$DESCRIPTION"
	echo "Project: $LONGNAME"
	echo "Location: $LOCATION"
	echo "Description: $DESCRIPTION"
    cd $LOCATION
	
    tmux new-session -d -c $LOCATION     -s $LONGNAME -n $LABEL_1 
    tmux new-window     -c $LOCATION     -t $LONGNAME -n $LABEL_2 nvim $LOCATION/main.go
    tmux new-window     -c $LOCATION/web -t $LONGNAME -n $LABEL_3 nvim $LOCATION/web/package.json
    tmux new-window     -c $HOME/org     -t $LONGNAME -n $LABEL_4 nvim $ORGFILE
    tmux new-window     -c $LOCATION     -t $LONGNAME -n $LABEL_5 claude
	tmux new-window     -c $LOCATION     -t $LONGNAME -n $LABEL_6 lazygit
    tmux attach -t $LOCAL
end

