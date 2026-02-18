#!/usr/bin/env python3
import os
import ssl
import certifi

# Set SSL certificate path for macOS
os.environ['SSL_CERT_FILE'] = certifi.where()
os.environ['REQUESTS_CA_BUNDLE'] = certifi.where()

# Now run the slash bot
import slash_bot

if __name__ == "__main__":
    slash_bot.main()
