#!/bin/bash

# Discord YouTube Bot Setup Script
# This script sets up the development environment

set -e

echo "🎵 Discord YouTube Bot Setup"
echo "============================"

# Check if Python 3.11+ is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.11 or higher."
    exit 1
fi

# Check Python version
python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
required_version="3.11"

if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Python $python_version is installed, but Python 3.11+ is required."
    exit 1
fi

echo "✅ Python $python_version detected"

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "⬆️ Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📚 Installing dependencies..."
pip install -r requirements.txt

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p downloads logs

# Copy environment file
if [ ! -f .env ]; then
    echo "📝 Creating environment file..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your Discord bot token and other settings"
else
    echo "✅ Environment file already exists"
fi

# Set permissions
echo "🔐 Setting permissions..."
chmod +x scripts/*.sh 2>/dev/null || true

# Check if Docker is installed
if command -v docker &> /dev/null; then
    echo "✅ Docker is installed"
    
    if command -v docker-compose &> /dev/null; then
        echo "✅ Docker Compose is installed"
    else
        echo "⚠️  Docker Compose is not installed. Install it for easy deployment."
    fi
else
    echo "⚠️  Docker is not installed. Install it for containerized deployment."
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your Discord bot token"
echo "2. Run the bot locally: source venv/bin/activate && python bot.py"
echo "3. Or run with Docker: docker-compose up -d"
echo ""
echo "For help, see README.md"
