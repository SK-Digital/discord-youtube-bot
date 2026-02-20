#!/usr/bin/env python3
"""
Convert cookies.txt to environment variable format for Coolify
"""

import sys
import os

def convert_cookies_to_env(cookies_file_path):
    """Convert cookies.txt file to environment variable format"""
    try:
        with open(cookies_file_path, 'r') as f:
            cookies_content = f.read()
        
        # Convert to single line with \n escapes
        env_value = cookies_content.strip().replace('\n', '\\n')
        
        # Escape any other special characters for shell
        env_value = env_value.replace('"', '\\"').replace('$', '\\$')
        
        return env_value
        
    except FileNotFoundError:
        print(f"❌ Error: File {cookies_file_path} not found")
        return None
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return None

def main():
    if len(sys.argv) != 2:
        print("Usage: python convert_cookies.py <cookies.txt>")
        sys.exit(1)
    
    cookies_file = sys.argv[1]
    env_value = convert_cookies_to_env(cookies_file)
    
    if env_value:
        print("🍪 YouTube Cookies Environment Variable:")
        print("=" * 50)
        print(f"YOUTUBE_COOKIES=\"{env_value}\"")
        print("=" * 50)
        print("\n📋 Instructions:")
        print("1. Copy the line above")
        print("2. In Coolify, add YOUTUBE_COOKIES as an environment variable")
        print("3. Paste the entire value (including quotes)")
        print("4. Redeploy your bot")

if __name__ == "__main__":
    main()
