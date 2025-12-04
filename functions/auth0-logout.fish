function auth0-logout --description "Clear Auth0 tokens and logout"
    set -l logout_url_flag 0
    set -l help_flag 0

    # Parse arguments
    for arg in $argv
        switch $arg
            case --help -h
                set help_flag 1
            case --browser -b
                set logout_url_flag 1
        end
    end

    # Show help if requested
    if test $help_flag -eq 1
        echo "Usage: auth0-logout [OPTIONS]"
        echo ""
        echo "Clear Auth0 tokens from environment and storage."
        echo ""
        echo "Options:"
        echo "  -b, --browser    Also open browser to Auth0 logout URL"
        echo "  -h, --help       Show this help message"
        echo ""
        echo "Examples:"
        echo "  auth0-logout              # Clear local tokens only"
        echo "  auth0-logout --browser    # Clear tokens and logout from Auth0 session"
        return 0
    end

    # Check if .env.fish exists to get token file path
    set -l env_file ""
    if test -f .env.fish
        set env_file .env.fish
    else if test -f ~/.config/auth0/.env.fish
        set env_file ~/.config/auth0/.env.fish
    end

    # Source environment if available to get token file path
    if test -n "$env_file"
        source $env_file
    end

    # Set default token file if not specified
    set -q AUTH0_TOKEN_FILE; or set AUTH0_TOKEN_FILE "$HOME/.config/auth0/tokens.json"

    echo "🔓 Logging out from Auth0..."

    # Clear environment variables
    if set -q AUTH0_ACCESS_TOKEN
        set -e AUTH0_ACCESS_TOKEN
        echo "✓ Cleared ACCESS_TOKEN from environment"
    end

    if set -q AUTH0_ID_TOKEN
        set -e AUTH0_ID_TOKEN
        echo "✓ Cleared ID_TOKEN from environment"
    end

    if set -q AUTH0_REFRESH_TOKEN
        set -e AUTH0_REFRESH_TOKEN
        echo "✓ Cleared REFRESH_TOKEN from environment"
    end

    # Delete token file if it exists
    if test -f $AUTH0_TOKEN_FILE
        rm $AUTH0_TOKEN_FILE
        echo "✓ Deleted token file: $AUTH0_TOKEN_FILE"
    end

    # Open browser to Auth0 logout URL if requested
    if test $logout_url_flag -eq 1
        if set -q AUTH0_DOMAIN; and set -q AUTH0_CLIENT_ID
            # Build logout URL
            set -l return_url "http://localhost:8080"
            set -l logout_url "https://$AUTH0_DOMAIN/v2/logout?client_id=$AUTH0_CLIENT_ID&returnTo="(string escape --style=url $return_url)

            echo "🌍 Opening browser to complete Auth0 logout..."

            if command -v xdg-open >/dev/null
                xdg-open $logout_url 2>/dev/null
            else if command -v open >/dev/null
                open $logout_url 2>/dev/null
            else
                echo "⚠️  Could not open browser automatically"
                echo "Visit this URL to complete logout:"
                echo $logout_url
            end
        else
            echo "⚠️  Cannot open logout URL: AUTH0_DOMAIN or AUTH0_CLIENT_ID not set"
            echo "Local tokens have been cleared."
        end
    end

    echo ""
    echo "✨ Logout complete!"
end
