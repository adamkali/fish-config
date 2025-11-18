# Set up usage variables fror projects

set LOCATION_TO_CONFIG $HOME/.config/fish/functions/prj-config/
set LOCATION_TO_INTERNAL_TEMPLATWES $HOME/.config/fish/functions/prj-internal/
set INFO_FILE $LOCATION_TO_INTERNAL_TEMPLATWES/info.fish
set KILL_FILE $LOCATION_TO_INTERNAL_TEMPLATWES/kill.fish
set RUN_FILE $LOCATION_TO_INTERNAL_TEMPLATWES/run.fish

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
        set PROJECT (printf '%s\n' $(exa $LOCATION_TO_CONFIG)  | fzf  --preview="echo {}" --preview-window=up:3:wrap)
        set PROJECT $LOCATION_TO_CONFIG$PROJECT
        prj-run $PROJECT

# With one Argument

    case 1
        set PROJECT (printf '%s\n' $(exa $LOCATION_TO_CONFIG)  | fzf  --preview="echo {}" --preview-window=up:3:wrap)
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
    source $PROJECT/run.fish
    run
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

# Copy the template files

        cp $INFO_FILE $RESULT_INFO_FILE
        cp $KILL_FILE $RESULT_KILL_FILE
        cp $RUN_FILE $RESULT_RUN_FILE

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