#!/bin/bash

# Encode cookies.txt to base64 for Coolify environment variable
# Usage: ./encode_cookies.sh /path/to/cookies.txt

if [ -z "$1" ]; then
    echo "Usage: $0 <cookies.txt>"
    echo "Example: $0 ../cookies.txt"
    exit 1
fi

COOKIES_FILE="$1"

if [ ! -f "$COOKIES_FILE" ]; then
    echo "❌ Error: File $COOKIES_FILE not found"
    exit 1
fi

echo "🍪 Encoding cookies file: $COOKIES_FILE"
echo ""

# Encode to base64
ENCODED=$(base64 -w 0 < "$COOKIES_FILE")

echo "📋 Base64 encoded cookies:"
echo "================================"
echo "$ENCODED"
echo "================================"
echo ""
echo "📝 Instructions:"
echo "1. Copy the base64 string above"
echo "2. In Coolify, set YOUTUBE_COOKIES environment variable to:"
echo "   $ENCODED"
echo "3. Redeploy your bot"
echo ""
echo "✅ This bypasses all escape sequence issues!"
