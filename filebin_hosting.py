import requests
import logging
import os
import hashlib
import random
import string
import asyncio
import urllib.parse

logger = logging.getLogger('discord_bot')

class FilebinHosting:
    """File hosting using Filebin.net API"""
    
    BASE_URL = "https://filebin.net"
    
    @staticmethod
    def generate_bin_id(length=8):
        """Generate a random bin ID"""
        return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))
    
    @staticmethod
    def sanitize_filename(filename):
        """Sanitize filename for web use"""
        # Remove or replace problematic characters
        import re
        # Keep alphanumeric, spaces, hyphens, underscores, and dots
        sanitized = re.sub(r'[^\w\s\-\.]', '', filename)
        # Replace multiple spaces with single space
        sanitized = re.sub(r'\s+', ' ', sanitized)
        # Remove leading/trailing spaces
        sanitized = sanitized.strip()
        return sanitized
    
    @staticmethod
    def calculate_sha256(file_path):
        """Calculate SHA256 checksum of file"""
        sha256_hash = hashlib.sha256()
        with open(file_path, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256_hash.update(chunk)
        return sha256_hash.hexdigest()
    
    @staticmethod
    async def upload_file(file_path: str) -> str:
        """Upload file to Filebin.net and return download link"""
        try:
            # Generate a unique bin ID
            bin_id = FilebinHosting.generate_bin_id()
            original_filename = os.path.basename(file_path)
            filename = FilebinHosting.sanitize_filename(original_filename)
            
            # Calculate SHA256 checksum (optional but recommended)
            sha256_checksum = FilebinHosting.calculate_sha256(file_path)
            
            # Upload URL
            upload_url = f"{FilebinHosting.BASE_URL}/{bin_id}/{filename}"
            
            # Prepare headers with SHA256 checksum
            headers = {
                'Content-SHA256': sha256_checksum
            }
            
            # Upload file
            with open(file_path, 'rb') as file:
                response = requests.post(
                    upload_url,
                    data=file,
                    headers=headers
                )
            
            # Check response
            if response.status_code in [200, 201]:  # Both 200 and 201 are success codes
                # Add a small delay to allow Filebin to process the file
                await asyncio.sleep(1)
                
                # Parse the response to get actual bin info
                try:
                    response_data = response.json()
                    actual_bin_id = response_data.get('bin', {}).get('id', bin_id)
                    # Use URL encoding for the filename
                    encoded_filename = urllib.parse.quote(filename)
                    download_url = f"{FilebinHosting.BASE_URL}/{actual_bin_id}/{encoded_filename}"
                    logger.info(f"File uploaded successfully to Filebin: {download_url}")
                    logger.info(f"Bin details: {response_data.get('bin', {})}")
                    logger.info(f"File details: {response_data.get('file', {})}")
                    return download_url
                except Exception as json_error:
                    # Fallback to constructed URL if JSON parsing fails
                    encoded_filename = urllib.parse.quote(filename)
                    download_url = f"{FilebinHosting.BASE_URL}/{bin_id}/{encoded_filename}"
                    logger.info(f"File uploaded (JSON parse failed): {download_url}")
                    return download_url
            else:
                logger.error(f"Upload failed with status {response.status_code}: {response.text}")
                raise Exception(f"Upload failed: HTTP {response.status_code}")
                
        except Exception as e:
            logger.error(f"Error uploading file to Filebin: {e}")
            raise Exception(f"Filebin upload failed: {str(e)}")
    
    @staticmethod
    async def get_bin_info(bin_id: str):
        """Get information about a bin"""
        try:
            url = f"{FilebinHosting.BASE_URL}/{bin_id}/"
            response = requests.get(url)
            
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"Failed to get bin info: HTTP {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Error getting bin info: {e}")
            return None
