# Set up usage variables fror projects

set LOCATION_TO_CONFIG $HOME/.config/fish/functions/prj-config/
set LOCATION_TO_INTERNAL_TEMPLATWES $HOME/.config/fish/functions/prj-internal/
set INFO_FILE $LOCATION_TO_INTERNAL_TEMPLATWES/info.fish
set KILL_FILE $LOCATION_TO_INTERNAL_TEMPLATWES/kill.fish
set RUN_FILE $LOCATION_TO_INTERNAL_TEMPLATWES/run.fish

# FZF color scheme environment variables with defaults	

set -q PRJ_PREVIEW_FZF_COLORS; or set -g PRJ_PREVIEW_FZF_COLORS "fg:#d0d0d0,bg:#121212,hl:#5f87af,fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff,info:#afaf87,prompt:#d7005f,pointer:#af5fff,marker:#87ff00,spinner:#af5fff,header:#87afaf"

# A function to Replace the `{+basename+} & {+location+}` template strings in the info file

function replace_basename_template --description "replace the {+basename+} template in the info file"
    set in_file $argv[1]
    set location $argv[2]
    sed -i "s/{+basename+}/$basename/g" $in_file
    sed -i "s/{+location+}/$location/g" $in_file
end

# Create the Root Function `prj` which manages what to do based on arguments

function prj --description "Use fzf to create a tmux session for a Project as configured above"
    switch (count $argv)

        # Base Usage

        case 0
            set PROJECT (printf '%s\n' $(exa $LOCATION_TO_CONFIG)  | fzf  --preview="prj-show {}" --preview-window=right:60%:wrap --color="$PRJ_PREVIEW_FZF_COLORS")
            set PROJECT $LOCATION_TO_CONFIG$PROJECT
            prj-run $PROJECT

            # With one Argument

        case 1
            set PROJECT (printf '%s\n' $(exa $LOCATION_TO_CONFIG)  | fzf  --preview="prj-show {}" --preview-window=right:60%:wrap --color="$PRJ_PREVIEW_FZF_COLORS")
            set PROJECT $LOCATION_TO_CONFIG$PROJECT
            if test "$argv[1]" = kill
                prj-kill $PROJECT
            else if test "$argv[1]" = run
                prj-run $PROJECT
            else if test "$argv[1]" = create
                echo "Not enough arguments to create project"
                exit 1
            else if test "$argv[1]" = help
                help
            end

            # With two Arguments

        case 2
            if test "$argv[1]" = create
                prj-create $argv[2]
            else if test "$argv[1]" = help
                help
            else if test "$argv[1]" = run
                set PROJECT $$LOCATION_TO_CONFIG$argv[2]
                if test -d $PROJECT
                    prj-run $PROJECT
                else
                    echo "Project does not exist"
                    exit 2
                end
            else if test "$argv[1]" = kill
                set PROJECT $LOCATION_TO_CONFIG$argv[2]
                if test -d $PROJECT
                    prj-kill $PROJECT
                else
                    echo "Project does not exist"
                    exit 2
                end
            end

            # Catch all

        case '*'
            echo "Unknown argument: $argv[1]"
            help
            exit 3
    end
end

# Run command

function prj-run --description "load the run script for a project"
    set PROJECT $argv[1]
    echo "Project: $PROJECT"

    # Source the info file to get the session name
    source $PROJECT/info.fish

    # Check if the session already exists
    if tmux has-session -t "$LONGNAME" 2>/dev/null
        echo "Session '$LONGNAME' already exists. Attaching..."
        tmux attach -t "$LONGNAME"
    else
        echo "Creating new session '$LONGNAME'..."
        source $PROJECT/run.fish
        run
    end
    exit 0
end

# Kill command

function prj-kill --description "load the kill script for a project"
    set PROJECT $argv[1]
    echo "Project: $PROJECT"
    source $PROJECT/kill.fish
    kill
    exit 0
end

# Create command

function prj-create --description "create a new project"
    if test -d $argv[1]
        echo "Path already exists"
        set NAME (basename $argv[1])
        mkdir -p $LOCATION_TO_CONFIG$NAME
        if ! test -d $LOCATION_TO_CONFIG$NAME
            echo "Failed to create project directory"
            exit 1
        end

        # Create the Result file names

        set $RESULT_INFO_FILE $LOCATION_TO_CONFIG$NAME/info.fish
        set $RESULT_KILL_FILE $LOCATION_TO_CONFIG$NAME/kill.fish
        set $RESULT_RUN_FILE $LOCATION_TO_CONFIG$NAME/run.fish

        # Create the files

        write_file_info_file
        write_file_kill_file
        write_file_run_file

        # Replace the template strings in the result files with the project name and location respectively

        replace_basename_template $NAME $RESULT_INFO_FILE
        replace_basename_template $NAME $RESULT_KILL_FILE
        replace_basename_template $NAME $RESULT_RUN_FILE

        # Exit or error

        exit 0
    else
        echo "Path does not exist! "
        exit 1
    end
end

# Help

function help --description "print the help message"
    echo prj
    echo "prj kill <project>"
    echo "prj run <project>"
    echo "prj create <location>"
    echo "prj help"
end

# Create the result info file

function write_file_info_file --description "touch the result files"
    touch $RESULT_INFO_FILE
    echo '
set -g SHORTNAME {+basename+}
set -g LONGNAME "{}" # these empty ones are replaced manually
set -g DESCRIPTION "{}"
set -g LOCATION {+location+} 

set -g LABEL_1 " Compile "
' >>$RESULT_INFO_FILE
end

# Touch the result kill file

function write_file_kill_file --description "touch the result files"
    touch $RESULT_KILL_FILE
    echo "
source $HOME/.config/fish/functions/prj-config/{+basename+}/info.fish
function kill
if tmux ls | grep -q $LONGNAME
tmux kill-session -t $LONGNAME
end
end
" >>$RESULT_KILL_FILE
end

# Touch the result run file

function write_file_run_file --description "touch the result files"
    touch $RESULT_RUN_FILE
    echo '
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
' >>$RESULT_RUN_FILE
end
