#!/bin/bash

# GitHub Repository Setup Script
# This script helps you add the remote and push to GitHub

set -e

echo "🚀 GitHub Repository Setup for Discord YouTube Bot"
echo "=================================================="

# Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Git repository not initialized. Run this from the repository root."
    exit 1
fi

# Get repository name
REPO_NAME="discord-youtube-bot"
GITHUB_USERNAME="SK-Digital"

echo "📋 Repository Details:"
echo "  Username: $GITHUB_USERNAME"
echo "  Repository: $REPO_NAME"
echo ""

# Check if remote already exists
if git remote get-url origin 2>/dev/null; then
    echo "⚠️  Remote 'origin' already exists:"
    git remote get-url origin
    echo ""
    read -p "Do you want to remove it and add the new remote? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
        echo "✅ Removed existing remote"
    else
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Add the remote
echo "🔗 Adding GitHub remote..."
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

echo "✅ Remote added: origin -> https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo ""

# Check if we can push
echo "🔄 Pushing to GitHub..."
echo "⚠️  Make sure you've created the repository on GitHub first!"
echo "   1. Go to: https://github.com/$GITHUB_USERNAME/new"
echo "   2. Repository name: $REPO_NAME"
echo "   3. Description: Discord YouTube to WAV Converter Bot"
echo "   4. Make it Public"
echo "   5. Don't initialize with README (we already have one)"
echo "   6. Click 'Create repository'"
echo ""
read -p "Press Enter after you've created the repository on GitHub..."

# Push to GitHub
git push -u origin main

echo ""
echo "🎉 Successfully pushed to GitHub!"
echo "📁 Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "Next steps:"
echo "1. Visit your repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "2. Add topics: discord, youtube, bot, python, wav-converter"
echo "3. Enable GitHub Actions if you want CI/CD"
echo "4. Add a README badge if desired"
echo ""
echo "🐳 For Docker deployment:"
echo "  docker-compose up -d"
echo ""
echo "🛠️ For local development:"
echo "  cp .env.example .env"
echo "  # Edit .env with your Discord bot token"
echo "  python run_slash_bot.py"
