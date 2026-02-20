import discord
import os
import asyncio
import tempfile
import logging
from discord.ext import commands
import yt_dlp
import subprocess
from dotenv import load_dotenv
from filebin_hosting import FilebinHosting

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger('discord_bot')

# Bot configuration
BOT_TOKEN = os.getenv('DISCORD_BOT_TOKEN')
MAX_FILE_SIZE_MB = int(os.getenv('MAX_FILE_SIZE_MB', '10'))
TEST_GUILD_ID = 1369930570536058951  # Your test server guild ID

# YouTube download options
YDL_OPTS = {
    'format': 'bestaudio/best',
    'quiet': True,
    'no_warnings': True,
    'extract_flat': False,
    'outtmpl': '%(title)s.%(ext)s',
    'noplaylist': True,
    'max_filesize': MAX_FILE_SIZE_MB * 1024 * 1024,
}

# Add cookies file if available
cookies_file = os.getenv('YOUTUBE_COOKIES_FILE')
if cookies_file and os.path.exists(cookies_file):
    YDL_OPTS['cookiefile'] = cookies_file
    logger.info(f"🍪 Using YouTube cookies file: {cookies_file}")
else:
    logger.info("⚠️  No YouTube cookies file available")

# Initialize bot with minimal intents
intents = discord.Intents.default()
bot = commands.Bot(command_prefix='!', intents=intents)

class YouTubeConverter:
    """Handles YouTube audio extraction and conversion"""
    
    @staticmethod
    async def validate_url(url: str) -> bool:
        """Validate if URL is a valid YouTube URL"""
        valid_domains = ['youtube.com', 'youtu.be', 'www.youtube.com']
        return any(domain in url for domain in valid_domains)
    
    @staticmethod
    async def download_audio(url: str, temp_dir: str) -> tuple[str, str]:
        """Download audio from YouTube URL"""
        try:
            ydl_opts = YDL_OPTS.copy()
            ydl_opts['outtmpl'] = os.path.join(temp_dir, '%(title)s.%(ext)s')
            
            # Add cookies file if available
            cookies_file = os.getenv('YOUTUBE_COOKIES_FILE')
            if cookies_file and os.path.exists(cookies_file):
                ydl_opts['cookiefile'] = cookies_file
            
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                info = ydl.extract_info(url, download=True)
                title = info['title']
                filename = ydl.prepare_filename(info)
                
                safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
                safe_filename = os.path.join(temp_dir, f"{safe_title}.{info['ext']}")
                
                if os.path.exists(filename) and filename != safe_filename:
                    os.rename(filename, safe_filename)
                
                return title, safe_filename
                
        except Exception as e:
            logger.error(f"Error downloading audio: {e}")
            raise Exception(f"Failed to download audio: {str(e)}")
    
    @staticmethod
    async def convert_to_wav(input_file: str, output_file: str) -> None:
        """Convert audio file to 16-bit 44.1kHz WAV format"""
        try:
            cmd = [
                'ffmpeg',
                '-i', input_file,
                '-acodec', 'pcm_s16le',
                '-ar', '44100',
                '-ac', '1',
                '-y',
                output_file
            ]
            
            logger.info(f"Converting {input_file} to {output_file}")
            process = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            stdout, stderr = await process.communicate()
            
            if process.returncode != 0:
                error_msg = stderr.decode() if stderr else "Unknown error"
                logger.error(f"FFmpeg conversion failed: {error_msg}")
                raise Exception(f"Audio conversion failed: {error_msg}")
            
            logger.info(f"Successfully converted to {output_file}")
            
        except Exception as e:
            logger.error(f"Error converting audio: {e}")
            raise Exception(f"Failed to convert audio: {str(e)}")
    
    @staticmethod
    async def check_file_size(file_path: str) -> bool:
        """Check if file size is within Discord limits"""
        file_size = os.path.getsize(file_path)
        max_size = MAX_FILE_SIZE_MB * 1024 * 1024
        return file_size <= max_size

@bot.event
async def on_ready():
    """Event when bot is ready"""
    logger.info(f'Bot logged in as {bot.user.name}')
    logger.info(f'Bot ID: {bot.user.id}')
    logger.info('------')
    logger.info('YouTube to WAV Converter Bot is ready!')
    
    # First try to sync globally
    try:
        synced = await bot.tree.sync()
        logger.info(f"Synced {len(synced)} slash command(s) globally")
    except Exception as e:
        logger.error(f"Failed to sync commands globally: {e}")
    
    # Then try to sync to test guild for instant registration
    try:
        guild = discord.Object(id=TEST_GUILD_ID)
        guild_synced = await bot.tree.sync(guild=guild)
        logger.info(f"Synced {len(guild_synced)} slash command(s) to test guild {TEST_GUILD_ID}")
    except Exception as e:
        logger.error(f"Failed to sync commands to test guild: {e}")
        logger.info("Make sure the bot is in the test server and has 'applications.commands' scope")

@bot.hybrid_command(name='youtube', description='Convert YouTube video to 16-bit 44.1kHz WAV')
async def youtube_convert(ctx, youtube_url: str):
    """Convert YouTube video to 16-bit 44.1kHz WAV format"""
    
    if not await YouTubeConverter.validate_url(youtube_url):
        try:
            await ctx.send("❌ Please provide a valid YouTube URL")
        except:
            pass  # Interaction expired
        return
    
    if hasattr(ctx, 'channel') and ctx.channel.permissions_for(ctx.guild.me).attach_files:
        try:
            processing_msg = await ctx.send("🔄 Processing your YouTube link...")
        except discord.errors.NotFound:
            # Interaction expired, can't send follow-up
            return
    else:
        try:
            await ctx.send("❌ I don't have permission to upload files in this channel!")
        except:
            pass
        return
    
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            logger.info(f"Created temporary directory: {temp_dir}")
            
            try:
                await processing_msg.edit(content="⬇️ Downloading audio from YouTube...")
            except discord.errors.NotFound:
                # Interaction expired, can't update message
                pass
            
            title, audio_file = await YouTubeConverter.download_audio(youtube_url, temp_dir)
            
            try:
                await processing_msg.edit(content="🔄 Converting to 16-bit 44.1kHz WAV...")
            except discord.errors.NotFound:
                pass
            
            wav_file = os.path.join(temp_dir, f"{title}.wav")
            await YouTubeConverter.convert_to_wav(audio_file, wav_file)
            
            file_size = os.path.getsize(wav_file)
            file_size_mb = file_size / (1024 * 1024)
            
            safe_filename = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
            discord_filename = f"{safe_filename}.wav"
            
            if file_size_mb <= MAX_FILE_SIZE_MB:
                # File is small enough for Discord upload
                try:
                    await processing_msg.edit(content="⬆️ Uploading to Discord...")
                except discord.errors.NotFound:
                    pass
                
                try:
                    await processing_msg.delete()
                except:
                    pass
                
                await ctx.send(
                    f"✅ **{title}** converted successfully!\n"
                    f"📊 Format: 16-bit 44.1kHz WAV\n"
                    f"📁 Size: {file_size_mb:.1f}MB",
                    file=discord.File(wav_file, discord_filename)
                )
            else:
                # File is too large, upload to Filebin
                try:
                    await processing_msg.edit(content="☁️ Uploading to Filebin.net...")
                except discord.errors.NotFound:
                    pass
                
                try:
                    # Use Filebin.net hosting
                    download_link = await FilebinHosting.upload_file(wav_file)
                    
                    try:
                        await processing_msg.delete()
                    except:
                        pass
                    
                    await ctx.send(
                        f"✅ **{title}** converted successfully!\n"
                        f"📊 Format: 16-bit 44.1kHz WAV\n"
                        f"📁 Size: {file_size_mb:.1f}MB (too large for Discord)\n"
                        f"🔗 Download link: {download_link}\n\n"
                        f"⚠️ Filebin links expire after 6 hours - download soon!\n"
                        f"💡 Right-click link and save as..."
                    )
                    
                except Exception as hosting_error:
                    try:
                        await processing_msg.edit(
                            content=f"❌ File too large ({file_size_mb:.1f}MB) and Filebin upload failed: {str(hosting_error)}"
                        )
                    except:
                        await ctx.send(f"❌ File too large ({file_size_mb:.1f}MB) and Filebin upload failed: {str(hosting_error)}")
                    return
            
            logger.info(f"Successfully converted: {title} ({file_size_mb:.1f}MB)")
            
    except Exception as e:
        logger.error(f"Error in youtube_convert: {e}")
        try:
            await processing_msg.edit(content=f"❌ Error: {str(e)}")
        except:
            await ctx.send(f"❌ Error: {str(e)}")

@bot.hybrid_command(name='help_youtube', description='Show help for YouTube converter')
async def help_youtube(ctx):
    """Show help for the YouTube converter command"""
    help_text = f"""
🎵 **YouTube to WAV Converter Bot**

**Commands:**
`/youtube <url>` - Convert YouTube video to 16-bit 44.1kHz WAV

**Format:**
- 🎧 Bit depth: 16-bit
- 📊 Sample rate: 44.1kHz
- 🎵 Channels: Mono
- 📁 Format: WAV

**File Handling:**
- 📏 Small files (≤{MAX_FILE_SIZE_MB}MB): Uploaded directly to Discord
- ☁️ Large files (>{MAX_FILE_SIZE_MB}MB): Uploaded to Filebin.net with download link
- ⚠️ Filebin links expire after 6 hours - download promptly

**Example:**
`/youtube https://www.youtube.com/watch?v=dQw4w9WgXcQ`

**Note:** Make sure the bot has permission to upload files!
    """
    
    await ctx.send(help_text)

@bot.hybrid_command(name='ping', description='Check bot latency')
async def ping(ctx):
    """Check bot latency"""
    latency = round(bot.latency * 1000)
    await ctx.send(f"🏓 Pong! Latency: {latency}ms")

def main():
    """Main function to run the bot"""
    if not BOT_TOKEN:
        logger.error("DISCORD_BOT_TOKEN not found in environment variables!")
        return
    
    try:
        logger.info("Starting YouTube to WAV Converter Bot...")
        bot.run(BOT_TOKEN)
        
    except Exception as e:
        logger.error(f"Failed to start bot: {e}")

if __name__ == "__main__":
    main()
