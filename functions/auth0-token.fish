function auth0-token --description "Display or work with Auth0 tokens"
    set -l show_all 0
    set -l show_access 0
    set -l show_id 0
    set -l show_refresh 0
    set -l decode_flag 0
    set -l copy_flag 0
    set -l export_flag 0
    set -l load_flag 0
    set -l help_flag 0

    # Parse arguments
    for arg in $argv
        switch $arg
            case --help -h
                set help_flag 1
            case --all -a
                set show_all 1
            case --access
                set show_access 1
            case --id
                set show_id 1
            case --refresh
                set show_refresh 1
            case --decode -d
                set decode_flag 1
            case --copy -c
                set copy_flag 1
            case --export -e
                set export_flag 1
            case --load -l
                set load_flag 1
        end
    end

    # Show help if requested
    if test $help_flag -eq 1
        echo "Usage: auth0-token [OPTIONS]"
        echo ""
        echo "Display or work with Auth0 tokens."
        echo ""
        echo "Options:"
        echo "  -a, --all        Show all tokens (default)"
        echo "      --access     Show only access token"
        echo "      --id         Show only ID token"
        echo "      --refresh    Show only refresh token"
        echo "  -d, --decode     Decode JWT tokens to show claims"
        echo "  -c, --copy       Copy access token to clipboard"
        echo "  -e, --export     Print export commands for current shell"
        echo "  -l, --load       Load tokens from file to environment"
        echo "  -h, --help       Show this help message"
        echo ""
        echo "Examples:"
        echo "  auth0-token                  # Show all tokens"
        echo "  auth0-token --access         # Show access token only"
        echo "  auth0-token --decode         # Show decoded token claims"
        echo "  auth0-token --copy           # Copy access token to clipboard"
        echo "  auth0-token --export         # Print export commands"
        echo "  auth0-token --load           # Load tokens from file"
        return 0
    end

    # Load tokens from file if requested
    if test $load_flag -eq 1
        # Check if .env.fish exists
        set -l env_file ""
        if test -f .env.fish
            set env_file .env.fish
        else if test -f ~/.config/auth0/.env.fish
            set env_file ~/.config/auth0/.env.fish
        end

        if test -n "$env_file"
            source $env_file
        end

        # Set default token file if not specified
        set -q AUTH0_TOKEN_FILE; or set AUTH0_TOKEN_FILE "$HOME/.config/auth0/tokens.json"

        if test ! -f $AUTH0_TOKEN_FILE
            echo "❌ Error: Token file not found at $AUTH0_TOKEN_FILE"
            echo "Run 'auth0-login' first to authenticate."
            return 1
        end

        echo "📂 Loading tokens from $AUTH0_TOKEN_FILE..."

        # Load tokens from file
        set -l access_token (cat $AUTH0_TOKEN_FILE | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))")
        set -l id_token (cat $AUTH0_TOKEN_FILE | python3 -c "import sys, json; print(json.load(sys.stdin).get('id_token', ''))")
        set -l refresh_token (cat $AUTH0_TOKEN_FILE | python3 -c "import sys, json; print(json.load(sys.stdin).get('refresh_token', ''))")

        if test -n "$access_token"
            set -gx AUTH0_ACCESS_TOKEN $access_token
            echo "✓ Loaded ACCESS_TOKEN"
        end

        if test -n "$id_token"
            set -gx AUTH0_ID_TOKEN $id_token
            echo "✓ Loaded ID_TOKEN"
        end

        if test -n "$refresh_token"
            set -gx AUTH0_REFRESH_TOKEN $refresh_token
            echo "✓ Loaded REFRESH_TOKEN"
        end

        echo ""
        echo "✨ Tokens loaded into environment!"
        return 0
    end

    # Check if tokens are available
    if not set -q AUTH0_ACCESS_TOKEN; and not set -q AUTH0_ID_TOKEN; and not set -q AUTH0_REFRESH_TOKEN
        echo "❌ No tokens found in environment."
        echo ""
        echo "Run 'auth0-login' to authenticate, or 'auth0-token --load' to load from file."
        return 1
    end

    # Default to showing all if no specific token requested
    if test $show_all -eq 0; and test $show_access -eq 0; and test $show_id -eq 0; and test $show_refresh -eq 0
        set show_all 1
    end

    # Copy access token to clipboard if requested
    if test $copy_flag -eq 1
        if not set -q AUTH0_ACCESS_TOKEN
            echo "❌ No access token available"
            return 1
        end

        if command -v xclip >/dev/null
            echo -n $AUTH0_ACCESS_TOKEN | xclip -selection clipboard
            echo "✓ Access token copied to clipboard"
        else if command -v pbcopy >/dev/null
            echo -n $AUTH0_ACCESS_TOKEN | pbcopy
            echo "✓ Access token copied to clipboard"
        else
            echo "❌ No clipboard utility found (install xclip or use pbcopy)"
            return 1
        end
        return 0
    end

    # Export commands if requested
    if test $export_flag -eq 1
        echo "# Copy and paste these commands to set tokens in your shell:"
        echo ""
        if set -q AUTH0_ACCESS_TOKEN
            echo "set -gx AUTH0_ACCESS_TOKEN '$AUTH0_ACCESS_TOKEN'"
        end
        if set -q AUTH0_ID_TOKEN
            echo "set -gx AUTH0_ID_TOKEN '$AUTH0_ID_TOKEN'"
        end
        if set -q AUTH0_REFRESH_TOKEN
            echo "set -gx AUTH0_REFRESH_TOKEN '$AUTH0_REFRESH_TOKEN'"
        end
        return 0
    end

    # Function to decode JWT token
    function _decode_jwt
        set -l token $argv[1]
        # Split token into parts
        set -l parts (string split "." $token)
        if test (count $parts) -ne 3
            echo "Invalid JWT format"
            return 1
        end

        # Decode payload (second part)
        set -l payload $parts[2]
        # Add padding if needed
        set -l padding (math "4 - "(string length $payload)" % 4")
        if test $padding -ne 4
            set payload "$payload"(string repeat -n $padding "=")
        end

        # Base64 decode and format JSON
        echo $payload | tr '_-' '/+' | base64 -d 2>/dev/null | python3 -m json.tool
    end

    # Display tokens
    echo "🔑 Auth0 Tokens"
    echo "═══════════════════════════════════════════════════════════"
    echo ""

    # Show access token
    if test $show_all -eq 1; or test $show_access -eq 1
        if set -q AUTH0_ACCESS_TOKEN
            echo "📝 Access Token:"
            if test $decode_flag -eq 1
                echo "---"
                _decode_jwt $AUTH0_ACCESS_TOKEN
                echo "---"
            else
                echo $AUTH0_ACCESS_TOKEN
            end
            echo ""
        else
            echo "⚠️  Access Token: Not available"
            echo ""
        end
    end

    # Show ID token
    if test $show_all -eq 1; or test $show_id -eq 1
        if set -q AUTH0_ID_TOKEN
            echo "🆔 ID Token:"
            if test $decode_flag -eq 1
                echo "---"
                _decode_jwt $AUTH0_ID_TOKEN
                echo "---"
            else
                echo $AUTH0_ID_TOKEN
            end
            echo ""
        else if test $show_all -eq 1
            echo "⚠️  ID Token: Not available"
            echo ""
        end
    end

    # Show refresh token
    if test $show_all -eq 1; or test $show_refresh -eq 1
        if set -q AUTH0_REFRESH_TOKEN
            echo "🔄 Refresh Token:"
            echo $AUTH0_REFRESH_TOKEN
            echo ""
        else if test $show_all -eq 1
            echo "⚠️  Refresh Token: Not available"
            echo ""
        end
    end

    echo "═══════════════════════════════════════════════════════════"
    echo "Use 'auth0-token --help' to see all options"
end
