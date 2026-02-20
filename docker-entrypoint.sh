#!/bin/bash

# Docker entrypoint script for Discord YouTube Bot
# This script handles environment variables and starts the bot

set -e

echo "🎵 Starting Discord YouTube Bot..."
echo "=================================="

# Check required environment variables
if [ -z "$DISCORD_BOT_TOKEN" ]; then
    echo "❌ ERROR: DISCORD_BOT_TOKEN environment variable is required"
    exit 1
fi

# Set default values for optional environment variables
export PREFIX=${PREFIX:-"!"}
export MAX_FILE_SIZE_MB=${MAX_FILE_SIZE_MB:-10}
export LOG_LEVEL=${LOG_LEVEL:-INFO}
export TEST_GUILD_ID=${TEST_GUILD_ID:-""}

# Handle YouTube cookies if provided
if [ -n "$YOUTUBE_COOKIES" ]; then
    echo "🍪 Creating YouTube cookies file..."
    
    # Debug: Show what we received
    echo "🔍 Raw YOUTUBE_COOKIES length: ${#YOUTUBE_COOKIES}"
    echo "🔍 First 100 chars: ${YOUTUBE_COOKIES:0:100}"
    
    # Fix Coolify's double escaping: \\" -> " and \\n -> \n
    echo "� Fixing Coolify escape sequences..."
    fixed_cookies=$(echo "$YOUTUBE_COOKIES" | sed 's/\\"/"/g' | sed 's/\\\\n/\\n/g')
    
    echo "📝 Creating cookies file with fixed content..."
    printf '%b\n' "$fixed_cookies" > /tmp/cookies.txt
    
    # Check if file looks correct
    if head -1 /tmp/cookies.txt | grep -q "Netscape HTTP Cookie File"; then
        echo "✅ Cookies file created successfully!"
    else
        echo "❌ Still not working, trying Python approach..."
        python3 -c "
import os
cookies = os.environ.get('YOUTUBE_COOKIES', '')
if cookies:
    # Fix double escaping: \\" -> " and \\n -> \n
    cookies = cookies.replace('\\\\\"', '\"').replace('\\\\n', '\\n')
    # Now convert to actual newlines
    cookies = cookies.replace('\\n', '\n')
    with open('/tmp/cookies.txt', 'w') as f:
        f.write(cookies)
"
        if head -1 /tmp/cookies.txt | grep -q "Netscape HTTP Cookie File"; then
            echo "✅ Python method successful!"
        else
            echo "❌ Creating minimal cookies file..."
            echo "# Netscape HTTP Cookie File" > /tmp/cookies.txt
        fi
    fi
    
    export YOUTUBE_COOKIES_FILE="/tmp/cookies.txt"
    echo "✅ YouTube cookies file created"
    
    # Show first few lines to verify format
    echo "📄 Cookies file preview:"
    head -5 /tmp/cookies.txt | sed 's/^/   /'
    echo "📄 File size: $(wc -l < /tmp/cookies.txt) lines"
else
    echo "⚠️  No YouTube cookies provided - some videos may be restricted"
    export YOUTUBE_COOKIES_FILE=""
fi

# Display configuration (without sensitive data)
echo "✅ Configuration:"
echo "  • PREFIX: $PREFIX"
echo "  • MAX_FILE_SIZE_MB: $MAX_FILE_SIZE_MB"
echo "  • LOG_LEVEL: $LOG_LEVEL"
echo "  • TEST_GUILD_ID: ${TEST_GUILD_ID:-"Not set"}"
echo "  • DISCORD_BOT_TOKEN: [REDACTED]"
echo "  • YOUTUBE_COOKIES: ${YOUTUBE_COOKIES:+[CONFIGURED]}"
echo ""

# Create necessary directories
mkdir -p downloads logs
echo "✅ Directories created/verified"

# Set SSL certificate path for Python if not set
if [ -z "$SSL_CERT_FILE" ]; then
    export SSL_CERT_FILE=$(python -c "import certifi; print(certifi.where())" 2>/dev/null || echo "")
    if [ -n "$SSL_CERT_FILE" ]; then
        export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
        echo "✅ SSL certificates configured"
    fi
fi

echo "🚀 Starting bot..."
exec python run_slash_bot.py
