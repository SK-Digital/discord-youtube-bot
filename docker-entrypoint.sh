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
    
    # Remove outer quotes if present (Coolify adds quotes around env vars)
    clean_cookies="$YOUTUBE_COOKIES"
    if [[ "$clean_cookies" == \"*\" ]]; then
        echo "🔧 Removing outer quotes from base64 string..."
        clean_cookies="${clean_cookies:1:-1}"
    fi
    
    # Use base64 to avoid all escape sequence issues
    echo "🔧 Using base64 to decode cookies..."
    echo "$clean_cookies" | base64 -d > /tmp/cookies.txt 2>/dev/null || {
        echo "❌ Base64 decode failed, creating minimal cookies file"
        echo "# Netscape HTTP Cookie File" > /tmp/cookies.txt
    }
    
    # Debug: Show what we actually wrote
    echo "🔍 File created, showing first 5 lines:"
    head -5 /tmp/cookies.txt | sed 's/^/   /'
    echo "🔍 File line count: $(wc -l < /tmp/cookies.txt)"
    echo "🔍 File size: $(wc -c < /tmp/cookies.txt) bytes"
    
    # Check if file looks correct
    if head -1 /tmp/cookies.txt | grep -q "Netscape HTTP Cookie File"; then
        echo "✅ Cookies file created successfully!"
    else
        echo "❌ First line doesn't match expected format"
        echo "🔍 Actual first line: '$(head -1 /tmp/cookies.txt)'"
        echo "❌ Creating minimal cookies file..."
        echo "# Netscape HTTP Cookie File" > /tmp/cookies.txt
        echo "🔧 Created minimal cookies file as fallback"
    fi
    
    export YOUTUBE_COOKIES_FILE="/tmp/cookies.txt"
    echo "✅ YouTube cookies file created"
    
    # Show final preview
    echo "📄 Final cookies file preview:"
    head -5 /tmp/cookies.txt | sed 's/^/   /'
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
