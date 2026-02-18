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

# Display configuration (without sensitive data)
echo "✅ Configuration:"
echo "  • PREFIX: $PREFIX"
echo "  • MAX_FILE_SIZE_MB: $MAX_FILE_SIZE_MB"
echo "  • LOG_LEVEL: $LOG_LEVEL"
echo "  • TEST_GUILD_ID: ${TEST_GUILD_ID:-"Not set"}"
echo "  • DISCORD_BOT_TOKEN: [REDACTED]"
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
