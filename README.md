# 🎵 Discord YouTube to WAV Converter Bot

A Discord bot that downloads YouTube videos and converts them to high-quality 16-bit 44.1kHz WAV audio files. Built with Python, discord.py, yt-dlp, and FFmpeg.

## 🚀 Features

- **High-Quality Audio**: Converts to 16-bit 44.1kHz WAV format
- **Smart File Handling**: Direct Discord upload for small files, Filebin.net hosting for large files
- **No YouTube API Required**: Uses yt-dlp directly - no API key needed
- **SSL Certificate Support**: Proper SSL handling for macOS/Linux
- **Docker Support**: Easy deployment with Docker and Docker Compose
- **Hybrid Commands**: Works with both slash commands and prefix commands
- **Error Handling**: Robust error handling and logging

## 📋 Requirements

- Python 3.11+
- Discord Bot Token
- FFmpeg (included in Docker image)
- No YouTube API key required!

## 🐳 Docker Deployment (Recommended)

### Quick Start

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/discord-youtube-bot.git
cd discord-youtube-bot
```

2. **Configure environment variables**

```bash
cp .env.example .env
# Edit .env with your Discord bot token
```

3. **Run with Docker Compose**

```bash
docker-compose up -d
```

### Manual Docker Build

```bash
# Build the image
docker build -t discord-youtube-bot .

# Run the container
docker run -d \
  --name discord-youtube-bot \
  --env-file .env \
  -v $(pwd)/downloads:/app/downloads \
  -v $(pwd)/logs:/app/logs \
  discord-youtube-bot
```

## 🛠️ Local Development

### Setup

1. **Clone and navigate**

```bash
git clone https://github.com/yourusername/discord-youtube-bot.git
cd discord-youtube-bot
```

2. **Create virtual environment**

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

4. **Configure environment**

```bash
cp .env.example .env
# Edit .env with your Discord bot token
```

5. **Run the bot**

```bash
python run_slash_bot.py
```

## ⚙️ Configuration

### Environment Variables

| Variable            | Description                             | Default  |
| ------------------- | --------------------------------------- | -------- |
| `DISCORD_BOT_TOKEN` | Discord bot token                       | Required |
| `PREFIX`            | Command prefix                          | `!`      |
| `MAX_FILE_SIZE_MB`  | Max file size for Discord upload        | `10`     |
| `TEST_GUILD_ID`     | Test server ID for instant command sync | Optional |
| `LOG_LEVEL`         | Logging level                           | `INFO`   |

### Discord Bot Setup

1. **Create a Discord Application**
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Create a new application
   - Add a bot user

2. **Enable Privileged Intents**
   - Go to Bot tab
   - Enable **Message Content Intent**

3. **Get Bot Token**
   - Copy the bot token
   - Add it to your `.env` file

4. **Invite Bot to Server**
   - Go to OAuth2 → URL Generator
   - Select scopes: `bot`, `applications.commands`
   - Select permissions: `Send Messages`, `Read Message History`, `Embed Links`, `Attach Files`
   - Copy the URL and invite to your server

## 📱 Commands

| Command          | Description                   | Usage                           |
| ---------------- | ----------------------------- | ------------------------------- |
| `/youtube <url>` | Download YouTube video as WAV | `/youtube https://youtu.be/...` |
| `!youtube <url>` | Same as slash command         | `!youtube https://youtu.be/...` |
| `/help_youtube`  | Show help information         | `/help_youtube`                 |
| `/ping`          | Check bot latency             | `/ping`                         |

## 📁 Project Structure

```
discord-youtube-bot/
├── slash_bot.py              # Main bot application
├── run_slash_bot.py          # SSL handling wrapper
├── filebin_hosting.py        # Filebin.net integration
├── requirements.txt           # Python dependencies
├── Dockerfile                # Docker configuration
├── docker-compose.yml        # Docker Compose configuration
├── .env.example              # Environment variables template
├── .gitignore                # Git ignore file
├── README.md                 # This file
├── downloads/                # Downloaded files (created automatically)
└── logs/                     # Log files (created automatically)
```

## 🔧 Audio Format

The bot converts all YouTube videos to:

- **Format**: WAV
- **Bit depth**: 16-bit
- **Sample rate**: 44.1kHz
- **Channels**: Mono
- **Quality**: Lossless

## 📁 File Handling

### Small Files (≤10MB)

- Uploaded directly to Discord
- Instant download available
- No expiration

### Large Files (>10MB)

- Uploaded to Filebin.net
- Download link provided
- Links expire after 6 hours
- Users should download promptly

## 🚨 Troubleshooting

### Common Issues

1. **Bot won't start**
   - Check Discord bot token in `.env`
   - Ensure bot has correct intents enabled
   - Check logs for error messages

2. **Downloads fail**
   - Verify YouTube URL is valid
   - Check internet connection
   - Ensure FFmpeg is installed (included in Docker)

3. **SSL Certificate Issues**
   - Use `run_slash_bot.py` for proper SSL handling
   - certifi is included in requirements

4. **Permission errors**
   - Ensure bot has `Send Messages`, `Embed Links`, and `Attach Files` permissions
   - Check file permissions for download directory

### Logs

Check logs for debugging:

```bash
# Docker logs
docker-compose logs -f

# Local logs
tail -f logs/bot.log
```

## 🎯 Features in Detail

### YouTubeConverter Class

- URL validation for YouTube domains
- Audio extraction using yt-dlp
- WAV conversion with FFmpeg
- File size checking

### FilebinHosting Class

- Automatic file upload for large files
- SHA256 checksum verification
- Filename sanitization
- Link generation

### Error Handling

- Graceful failure for invalid URLs
- File size limit enforcement
- Network error recovery
- User-friendly error messages

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [discord.py](https://discordpy.readthedocs.io/) - Discord API wrapper
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - YouTube downloader (no API key required!)
- [FFmpeg](https://ffmpeg.org/) - Audio processing
- [Filebin.net](https://filebin.net/) - File hosting service
- [Docker](https://www.docker.com/) - Containerization

## 📞 Support

If you need help:

- Create an issue on GitHub
- Contact the developer: [Shane Sweeney](https://caerus-online.xyz/)

---

Made with ❤️ by [Shane Sweeney](https://caerus-online.xyz/)
