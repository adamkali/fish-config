set LOCATION_TO_CONFIG $HOME/.config/fish/functions/prj-config/

# Unicode box-drawing characters for pretty borders
set BORDER_TOP_LEFT "╭"
set BORDER_TOP_RIGHT "╮"
set BORDER_BOTTOM_LEFT "╰"
set BORDER_BOTTOM_RIGHT "╯"
set BORDER_HORIZONTAL "─"
set BORDER_VERTICAL "│"

# Color scheme environment variables with defaults
# Users can override these in their config.fish or environment
set -q PRJ_PREVIEW_BORDER_COLOR; or set -g PRJ_PREVIEW_BORDER_COLOR "blue"
set -q PRJ_PREVIEW_TITLE_COLOR; or set -g PRJ_PREVIEW_TITLE_COLOR "cyan"
set -q PRJ_PREVIEW_LABEL_COLOR; or set -g PRJ_PREVIEW_LABEL_COLOR "yellow"
set -q PRJ_PREVIEW_TEXT_COLOR; or set -g PRJ_PREVIEW_TEXT_COLOR "normal"
set -q PRJ_PREVIEW_ICON_COLOR; or set -g PRJ_PREVIEW_ICON_COLOR "magenta"
set -q PRJ_PREVIEW_GIT_CLEAN_COLOR; or set -g PRJ_PREVIEW_GIT_CLEAN_COLOR "green"
set -q PRJ_PREVIEW_GIT_DIRTY_COLOR; or set -g PRJ_PREVIEW_GIT_DIRTY_COLOR "red"
set -q PRJ_PREVIEW_PATH_COLOR; or set -g PRJ_PREVIEW_PATH_COLOR "blue"

function prj-show --description "load the display script for a project"
    # Get project name from argument
    set project_name $argv[1]
    set project_path $LOCATION_TO_CONFIG$project_name

    # Source the project info
    if test -f $project_path/info.fish
        source $project_path/info.fish
    else
        echo "Project not found: $project_name"
        return 1
    end

    # Get git information if the location is in a git repo (checking parent dirs too)
    set git_repo_path $LOCATION

    # Check if location is in a git repository (including parent directories)
    set git_root (cd $git_repo_path 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null)

    if test -n "$git_root"
        # Use the git root for all git commands
        set -g GITSTATUS (cd $git_root && git status --porcelain 2>/dev/null)
        set -g GITBRANCH (cd $git_root && git branch --show-current 2>/dev/null)
        # Use string collect to preserve newlines in git log output
        set -g GITCOMMITS (cd $git_root && git log --pretty=format:"%h %ad | %s" --date=short --max-count=3 2>/dev/null | string collect)
        set -g GITROOT $git_root
    else
        set -g GITSTATUS ""
        set -g GITBRANCH ""
        set -g GITCOMMITS ""
        set -g GITROOT ""
    end

    # Display the project information
    prj-show_title "$LONGNAME"
    prj-show_description "$DESCRIPTION"
    prj-show_location "$LOCATION"
    prj-show_git_status
    prj-show_labels
end

function prj-show_title --description "title card for a project"
    set title $argv[1]
    set border_top (generate_border_top 64)
    set border_bottom (generate_border_bottom 64)

    echo ""
    echo $border_top
    format_line "$title" 64 $PRJ_PREVIEW_TITLE_COLOR
    echo $border_bottom
end

function prj-show_description --description "show project description"
    set description $argv[1]

    if test -n "$description"
        echo ""
        set_color $PRJ_PREVIEW_TEXT_COLOR
        printf "  %s\n" "$description"
        set_color normal
        echo ""
    end
end

function prj-show_location --description "show project location"
    set location $argv[1]

    if test -n "$location"
        set border_top (generate_border_top 64)
        set border_bottom (generate_border_bottom 64)
        echo $border_top
        format_line " $location" 64
        echo $border_bottom
    end
end

function prj-show_labels --description "show tmux window labels"
    set border_top (generate_border_top 64)
    set border_bottom (generate_border_bottom 64)

    echo $border_top
    format_line "WINDOWS" 64 $PRJ_PREVIEW_LABEL_COLOR
    format_line "" 64

    # Iterate through labels
    set label_num 1
    while set -q LABEL_$label_num
        set label_var LABEL_$label_num
        set label_value $$label_var
        if test -n "$label_value"
            format_line "  $label_num. $label_value" 64 $PRJ_PREVIEW_TEXT_COLOR
        end
        set label_num (math $label_num + 1)
    end

    echo $border_bottom
end

function prj-show_git_status --description "git status for a project"
    # If not in git repo, skip this section
    if test -z "$GITBRANCH"
        return
    end

    set border_top (generate_border_top 64)
    set border_bottom (generate_border_bottom 64)

    echo $border_top
    format_line " GIT STATUS" 64
    format_line "" 64

    # Show git root if different from project location (normalize paths by removing trailing slash)
    set normalized_location (string replace -r '/$' '' "$LOCATION")
    set normalized_gitroot (string replace -r '/$' '' "$GITROOT")

    if test -n "$GITROOT" -a "$normalized_gitroot" != "$normalized_location"
        format_line "Repo: $GITROOT" 64 $PRJ_PREVIEW_TEXT_COLOR
    end

    # Show branch
    if test -n "$GITBRANCH"
        format_line " Branch: $GITBRANCH" 64
    end

    # Show status
    if test -z "$GITSTATUS"
        format_line " Working tree clean" 64
    else
        set change_count (echo "$GITSTATUS" | wc -l)
        format_line " $change_count change(s)" 64
    end

    format_line "" 64

    # Show recent commits
    if test -n "$GITCOMMITS"
        format_line "Recent commits:" 64 $PRJ_PREVIEW_TEXT_COLOR
        # Split commits by newline and process each one
        for commit in (string split \n "$GITCOMMITS")
            if test -n "$commit"
                # Truncate commit message if longer than 50 chars
                set commit_len (string length "$commit")
                if test $commit_len -gt 50
                    set commit (string sub -l 47 "$commit")"..."
                end
                format_line "  • $commit" 64 $PRJ_PREVIEW_TEXT_COLOR
            end
        end
    end

    echo $border_bottom
end

function generate_border --description "generate a middle border line"
    set width 64
    if test (count $argv) -gt 0
        set width $argv[1]
    end

    # Create middle border with box-drawing characters
    set_color $PRJ_PREVIEW_BORDER_COLOR
    echo "$BORDER_HORIZONTAL"(string repeat -n (math $width - 2) "$BORDER_HORIZONTAL")"$BORDER_HORIZONTAL"
    set_color normal
end

function generate_border_top --description "generate a top border with rounded corners"
    set width 64
    if test (count $argv) -gt 0
        set width $argv[1]
    end

    # Create top border with rounded corners
    set_color $PRJ_PREVIEW_BORDER_COLOR
    echo "$BORDER_TOP_LEFT"(string repeat -n (math $width - 2) "$BORDER_HORIZONTAL")"$BORDER_TOP_RIGHT"
    set_color normal
end

function generate_border_bottom --description "generate a bottom border with rounded corners"
    set width 64
    if test (count $argv) -gt 0
        set width $argv[1]
    end

    # Create bottom border with rounded corners
    set_color $PRJ_PREVIEW_BORDER_COLOR
    echo "$BORDER_BOTTOM_LEFT"(string repeat -n (math $width - 2) "$BORDER_HORIZONTAL")"$BORDER_BOTTOM_RIGHT"
    set_color normal
end

function format_line --description "format a line with borders on both sides"
    set content $argv[1]
    set width 64
    set text_color $PRJ_PREVIEW_TEXT_COLOR

    if test (count $argv) -gt 1
        set width $argv[2]
    end

    if test (count $argv) -gt 2
        set text_color $argv[3]
    end

    # Calculate content width (total width - 2 for borders - 2 for padding)
    set content_width (math $width - 4)

    # Use printf with fixed width format and colors
    set_color $PRJ_PREVIEW_BORDER_COLOR
    printf "%s" "$BORDER_VERTICAL"
    set_color $text_color
    printf "  %-"$content_width"s " "$content"
    set_color $PRJ_PREVIEW_BORDER_COLOR
    printf "%s\n" "$BORDER_VERTICAL"
    set_color normal
end
