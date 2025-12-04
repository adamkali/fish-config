function auth0-login --description "Authenticate with Auth0 using OAuth 2.0 with PKCE"
    # Check if .env.fish exists in current directory or home
    set -l env_file ""
    if test -f .env.fish
        set env_file .env.fish
    else if test -f ~/.config/auth0/.env.fish
        set env_file ~/.config/auth0/.env.fish
    else
        echo "❌ Error: .env.fish not found!"
        echo "Create a .env.fish file in the current directory or ~/.config/auth0/"
        echo "See .env.fish.example for required variables"
        return 1
    end

    # Source the environment file
    source $env_file

    # Validate required variables
    if not set -q AUTH0_DOMAIN; or test -z "$AUTH0_DOMAIN"
        echo "❌ Error: AUTH0_DOMAIN not set in .env.fish"
        return 1
    end
    if not set -q AUTH0_CLIENT_ID; or test -z "$AUTH0_CLIENT_ID"
        echo "❌ Error: AUTH0_CLIENT_ID not set in .env.fish"
        return 1
    end

    # Set defaults for optional variables
    set -q AUTH0_CALLBACK_URL; or set -x AUTH0_CALLBACK_URL "http://localhost:8080/callback"
    set -q AUTH0_CALLBACK_PORT; or set -x AUTH0_CALLBACK_PORT "8080"
    set -q AUTH0_SCOPE; or set -x AUTH0_SCOPE "openid profile email"
    set -q AUTH0_TOKEN_FILE; or set -x AUTH0_TOKEN_FILE "$HOME/.config/auth0/tokens.json"

    echo "🔐 Starting Auth0 login flow..."
    echo "Domain: $AUTH0_DOMAIN"
    echo "Client ID: $AUTH0_CLIENT_ID"

    # Generate PKCE code verifier (43-128 character random string)
    set -l code_verifier (openssl rand -base64 64 | tr -d '\n' | tr -d '=' | tr '+/' '-_' | head -c 64)

    # Generate PKCE code challenge (SHA256 hash of verifier, base64url encoded)
    set -l code_challenge (echo -n $code_verifier | openssl dgst -sha256 -binary | openssl base64 | tr -d '\n' | tr -d '=' | tr '+/' '-_')

    echo "✓ Generated PKCE challenge"

    # Generate state parameter for CSRF protection
    set -l state (openssl rand -hex 16)

    # Create temporary directory for callback handling
    set -l temp_dir (mktemp -d)
    set -l callback_file "$temp_dir/callback.txt"
    set -l server_pid_file "$temp_dir/server.pid"

    # Build authorization URL
    set -l auth_url "https://$AUTH0_DOMAIN/authorize"
    set -l params "response_type=code"
    set -a params "client_id=$AUTH0_CLIENT_ID"
    set -a params "redirect_uri="(string escape --style=url $AUTH0_CALLBACK_URL)
    set -a params "scope="(string escape --style=url $AUTH0_SCOPE)
    set -a params "state=$state"
    set -a params "code_challenge=$code_challenge"
    set -a params "code_challenge_method=S256"

    # Add audience if specified
    if set -q AUTH0_AUDIENCE; and test -n "$AUTH0_AUDIENCE"
        set -a params "audience="(string escape --style=url $AUTH0_AUDIENCE)
    end

    set -l full_auth_url "$auth_url?"(string join "&" $params)

    # Start local callback server in background
    echo "🌐 Starting local callback server on port $AUTH0_CALLBACK_PORT..."

    # Use Python to create a simple HTTP server for the callback
    python3 -c "
import http.server
import socketserver
import urllib.parse
import sys

PORT = $AUTH0_CALLBACK_PORT
CALLBACK_FILE = '$callback_file'
SERVER_PID_FILE = '$server_pid_file'

class CallbackHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/callback'):
            # Parse query parameters
            query = urllib.parse.urlparse(self.path).query
            params = urllib.parse.parse_qs(query)

            # Write callback data to file
            with open(CALLBACK_FILE, 'w') as f:
                f.write(query)

            # Send success response
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'''
                <html><body style=\"font-family: sans-serif; text-align: center; padding: 50px;\">
                    <h1>✓ Authentication Successful!</h1>
                    <p>You can close this window and return to your terminal.</p>
                </body></html>
            ''')

            # Shutdown server after handling callback
            import threading
            threading.Thread(target=self.server.shutdown).start()
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Suppress server logs

with socketserver.TCPServer(('', PORT), CallbackHandler) as httpd:
    # Write PID for cleanup
    with open(SERVER_PID_FILE, 'w') as f:
        f.write(str(httpd.socket.fileno()))
    httpd.serve_forever()
" &
    set -l server_pid $last_pid

    # Give server a moment to start
    sleep 1

    echo "✓ Callback server ready"
    echo ""
    echo "🌍 Opening browser for authentication..."
    echo "If the browser doesn't open, visit this URL:"
    echo $full_auth_url
    echo ""

    # Open browser
    if command -v xdg-open >/dev/null
        xdg-open $full_auth_url 2>/dev/null
    else if command -v open >/dev/null
        open $full_auth_url 2>/dev/null
    else
        echo "⚠️  Could not open browser automatically"
    end

    echo "⏳ Waiting for authentication callback..."

    # Wait for callback (timeout after 2 minutes)
    set -l timeout 120
    set -l elapsed 0
    while test ! -f $callback_file; and test $elapsed -lt $timeout
        sleep 1
        set elapsed (math $elapsed + 1)
    end

    # Check if we got the callback
    if test ! -f $callback_file
        echo "❌ Authentication timeout - no callback received"
        kill $server_pid 2>/dev/null
        rm -rf $temp_dir
        return 1
    end

    # Parse callback parameters
    set -l callback_data (cat $callback_file)
    set -l auth_code ""
    set -l returned_state ""

    for param in (string split "&" $callback_data)
        set -l key_value (string split "=" $param)
        if test "$key_value[1]" = "code"
            set auth_code (string unescape --style=url $key_value[2])
        else if test "$key_value[1]" = "state"
            set returned_state $key_value[2]
        end
    end

    # Verify state parameter
    if test "$returned_state" != "$state"
        echo "❌ Error: State mismatch - possible CSRF attack!"
        rm -rf $temp_dir
        return 1
    end

    if test -z "$auth_code"
        echo "❌ Error: No authorization code received"
        rm -rf $temp_dir
        return 1
    end

    echo "✓ Authorization code received"
    echo "🔄 Exchanging code for tokens..."

    # Exchange authorization code for tokens
    set -l token_url "https://$AUTH0_DOMAIN/oauth/token"
    set -l token_response (curl -s -X POST $token_url \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=authorization_code" \
        -d "client_id=$AUTH0_CLIENT_ID" \
        -d "code=$auth_code" \
        -d "redirect_uri=$AUTH0_CALLBACK_URL" \
        -d "code_verifier=$code_verifier")

    # Check if token exchange was successful
    if echo $token_response | grep -q '"error"'
        echo "❌ Token exchange failed:"
        echo $token_response | python3 -m json.tool
        rm -rf $temp_dir
        return 1
    end

    # Extract tokens using Python for reliable JSON parsing
    set -l access_token (echo $token_response | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))")
    set -l id_token (echo $token_response | python3 -c "import sys, json; print(json.load(sys.stdin).get('id_token', ''))")
    set -l refresh_token (echo $token_response | python3 -c "import sys, json; print(json.load(sys.stdin).get('refresh_token', ''))")

    if test -z "$access_token"
        echo "❌ Error: No access token in response"
        rm -rf $temp_dir
        return 1
    end

    echo "✓ Tokens received successfully!"

    # Create token directory if it doesn't exist
    set -l token_dir (dirname $AUTH0_TOKEN_FILE)
    mkdir -p $token_dir

    # Save tokens to file
    echo $token_response | python3 -m json.tool >$AUTH0_TOKEN_FILE
    chmod 600 $AUTH0_TOKEN_FILE
    echo "✓ Tokens saved to: $AUTH0_TOKEN_FILE"

    # Export tokens to current session
    set -gx AUTH0_ACCESS_TOKEN $access_token
    set -gx AUTH0_ID_TOKEN $id_token
    if test -n "$refresh_token"
        set -gx AUTH0_REFRESH_TOKEN $refresh_token
    end

    echo ""
    echo "✨ Login successful!"
    echo ""
    echo "Tokens are now available as environment variables:"
    echo "  \$AUTH0_ACCESS_TOKEN"
    echo "  \$AUTH0_ID_TOKEN"
    if test -n "$refresh_token"
        echo "  \$AUTH0_REFRESH_TOKEN"
    end
    echo ""
    echo "Use 'auth0-token' to display tokens or 'auth0-logout' to clear them."

    # Cleanup
    rm -rf $temp_dir
end
