"""
Media Processing Service - Generate thumbnails and optimized versions
Handles images and videos with proper web optimization
"""
import os
import subprocess
from pathlib import Path
from PIL import Image, ImageOps
from typing import Dict, List, Tuple, Optional
import logging

logger = logging.getLogger(__name__)

class MediaProcessingService:
    """Fast media processing for web optimization"""
    
    # Size configurations
    THUMBNAIL_SIZE = (300, 300)
    WEB_SIZE = (1920, 1440) 
    PREVIEW_SIZE = (150, 150)
    
    # Quality settings
    THUMBNAIL_QUALITY = 85
    WEB_QUALITY = 90
    PREVIEW_QUALITY = 80
    
    def __init__(self, media_root: Path):
        self.media_root = Path(media_root)
        
    def process_media_file(self, file_path: Path, alert_id: str) -> Dict[str, str]:
        """
        Process uploaded media file and generate all variants
        Returns dict with URLs for all generated versions
        """
        try:
            file_extension = file_path.suffix.lower()
            
            if file_extension in ['.jpg', '.jpeg', '.png', '.webp']:
                return self._process_image(file_path, alert_id)
            elif file_extension in ['.mp4', '.mov', '.avi']:
                return self._process_video(file_path, alert_id)
            else:
                # Unknown file type, just return original
                return {
                    'original': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
                    'thumbnail': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
                    'web': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
                    'preview': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}'
                }
                
        except Exception as e:
            logger.error(f"Error processing media {file_path}: {e}")
            # Return original on error
            return {
                'original': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
                'thumbnail': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
                'web': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
                'preview': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}'
            }
    
    def _process_image(self, file_path: Path, alert_id: str) -> Dict[str, str]:
        """Process image file - generate thumbnail, web, and preview versions"""
        base_name = file_path.stem
        
        try:
            # Open and extract EXIF data first
            with Image.open(file_path) as img:
                # Extract comprehensive EXIF data before any processing
                exif_data = self._extract_exif_data(img)
                
                # Fix EXIF orientation
                img = ImageOps.exif_transpose(img)
                
                # Convert to RGB if necessary (handles PNG with transparency)
                if img.mode in ('RGBA', 'LA', 'P'):
                    rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'P':
                        img = img.convert('RGBA')
                    rgb_img.paste(img, mask=img.split()[-1] if img.mode in ('RGBA', 'LA') else None)
                    img = rgb_img
                
                # Generate thumbnail (square crop)
                thumb_path = file_path.parent / f"{base_name}.thumb.jpg"
                thumb_img = img.copy()
                thumb_img.thumbnail(self.THUMBNAIL_SIZE, Image.Resampling.LANCZOS)
                
                # Center crop to square
                width, height = thumb_img.size
                if width != height:
                    size = min(width, height)
                    left = (width - size) // 2
                    top = (height - size) // 2
                    thumb_img = thumb_img.crop((left, top, left + size, top + size))
                    thumb_img = thumb_img.resize(self.THUMBNAIL_SIZE, Image.Resampling.LANCZOS)
                
                thumb_img.save(thumb_path, 'JPEG', quality=self.THUMBNAIL_QUALITY, optimize=True)
                
                # Generate web version (maintain aspect ratio)
                web_path = file_path.parent / f"{base_name}.web.jpg"
                web_img = img.copy()
                web_img.thumbnail(self.WEB_SIZE, Image.Resampling.LANCZOS)
                web_img.save(web_path, 'JPEG', quality=self.WEB_QUALITY, optimize=True)
                
                # Generate preview (small square)
                preview_path = file_path.parent / f"{base_name}.preview.jpg"
                preview_img = img.copy()
                preview_img.thumbnail(self.PREVIEW_SIZE, Image.Resampling.LANCZOS)
                
                # Center crop to square for preview
                width, height = preview_img.size
                if width != height:
                    size = min(width, height)
                    left = (width - size) // 2
                    top = (height - size) // 2
                    preview_img = preview_img.crop((left, top, left + size, top + size))
                    preview_img = preview_img.resize(self.PREVIEW_SIZE, Image.Resampling.LANCZOS)
                
                preview_img.save(preview_path, 'JPEG', quality=self.PREVIEW_QUALITY, optimize=True)
                
        except Exception as e:
            logger.error(f"Error processing image {file_path}: {e}")
            # Return original URLs on error
            return self._get_original_urls(file_path, alert_id)
        
        result = {
            'original': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
            'thumbnail': f'https://api.ufobeep.com/media/{alert_id}/{base_name}.thumb.jpg',
            'web': f'https://api.ufobeep.com/media/{alert_id}/{base_name}.web.jpg',
            'preview': f'https://api.ufobeep.com/media/{alert_id}/{base_name}.preview.jpg'
        }
        
        # Add EXIF data if extracted successfully
        if exif_data:
            result['exif_data'] = exif_data
            
        return result
    
    def _process_video(self, file_path: Path, alert_id: str) -> Dict[str, str]:
        """Process video file - generate thumbnail from frame at 3 seconds"""
        base_name = file_path.stem
        
        try:
            # Extract frame at 3 seconds using ffmpeg
            thumb_path = file_path.parent / f"{base_name}.thumb.jpg"
            web_thumb_path = file_path.parent / f"{base_name}.web.jpg"
            preview_path = file_path.parent / f"{base_name}.preview.jpg"
            
            # Generate thumbnail at 3 seconds (or 10% of duration, whichever is smaller)
            cmd = [
                'ffmpeg', '-y',  # -y to overwrite
                '-i', str(file_path),
                '-ss', '3',  # Seek to 3 seconds
                '-vframes', '1',  # Extract 1 frame
                '-q:v', '2',  # High quality
                '-vf', f'scale={self.THUMBNAIL_SIZE[0]}:{self.THUMBNAIL_SIZE[1]}:force_original_aspect_ratio=increase,crop={self.THUMBNAIL_SIZE[0]}:{self.THUMBNAIL_SIZE[1]}',
                str(thumb_path)
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
            
            if result.returncode != 0:
                logger.warning(f"ffmpeg failed for {file_path}: {result.stderr}")
                # Fallback: create a placeholder thumbnail
                self._create_video_placeholder(thumb_path, self.THUMBNAIL_SIZE)
            
            # Generate web thumbnail (larger)
            if thumb_path.exists():
                with Image.open(thumb_path) as thumb_img:
                    # Create web version
                    web_img = thumb_img.copy()
                    web_img.thumbnail((800, 600), Image.Resampling.LANCZOS)
                    web_img.save(web_thumb_path, 'JPEG', quality=self.WEB_QUALITY, optimize=True)
                    
                    # Create preview version
                    preview_img = thumb_img.copy()
                    preview_img.thumbnail(self.PREVIEW_SIZE, Image.Resampling.LANCZOS)
                    preview_img.save(preview_path, 'JPEG', quality=self.PREVIEW_QUALITY, optimize=True)
            else:
                # Create placeholders if ffmpeg failed
                self._create_video_placeholder(web_thumb_path, (800, 600))
                self._create_video_placeholder(preview_path, self.PREVIEW_SIZE)
                
        except Exception as e:
            logger.error(f"Error processing video {file_path}: {e}")
            # Create placeholder thumbnails on error
            thumb_path = file_path.parent / f"{base_name}.thumb.jpg"
            web_thumb_path = file_path.parent / f"{base_name}.web.jpg"
            preview_path = file_path.parent / f"{base_name}.preview.jpg"
            
            self._create_video_placeholder(thumb_path, self.THUMBNAIL_SIZE)
            self._create_video_placeholder(web_thumb_path, (800, 600))
            self._create_video_placeholder(preview_path, self.PREVIEW_SIZE)
        
        return {
            'original': f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}',
            'thumbnail': f'https://api.ufobeep.com/media/{alert_id}/{base_name}.thumb.jpg',
            'web': f'https://api.ufobeep.com/media/{alert_id}/{base_name}.web.jpg',
            'preview': f'https://api.ufobeep.com/media/{alert_id}/{base_name}.preview.jpg'
        }
    
    def _create_video_placeholder(self, output_path: Path, size: Tuple[int, int]):
        """Create a video placeholder thumbnail"""
        try:
            # Create a simple dark gray placeholder with play icon
            img = Image.new('RGB', size, (64, 64, 64))
            
            # Add a simple play icon (triangle)
            from PIL import ImageDraw
            draw = ImageDraw.Draw(img)
            
            # Calculate play button size (20% of image)
            play_size = min(size) // 5
            center_x, center_y = size[0] // 2, size[1] // 2
            
            # Draw play triangle
            triangle_points = [
                (center_x - play_size//2, center_y - play_size//2),
                (center_x - play_size//2, center_y + play_size//2),
                (center_x + play_size//2, center_y)
            ]
            draw.polygon(triangle_points, fill=(255, 255, 255))
            
            img.save(output_path, 'JPEG', quality=85)
            
        except Exception as e:
            logger.error(f"Error creating video placeholder: {e}")
    
    def _extract_exif_data(self, img) -> Dict:
        """Diplomatically extract all available EXIF data from image"""
        exif_data = {}
        
        try:
            # Get raw EXIF data
            exif_dict = img._getexif() or {}
            
            # Camera/device info (varies wildly between phones)
            camera_info = {}
            camera_info['make'] = self._safe_get_exif(exif_dict, 271, 'Unknown')  # Make
            camera_info['model'] = self._safe_get_exif(exif_dict, 272, 'Unknown')  # Model
            camera_info['software'] = self._safe_get_exif(exif_dict, 305, 'Unknown')  # Software
            
            # Photo settings (critical for plate solving)
            photo_settings = {}
            photo_settings['datetime'] = self._safe_get_exif(exif_dict, 306, None)  # DateTime
            photo_settings['datetime_original'] = self._safe_get_exif(exif_dict, 36867, None)  # DateTimeOriginal
            photo_settings['datetime_digitized'] = self._safe_get_exif(exif_dict, 36868, None)  # DateTimeDigitized
            
            # Camera settings for astronomical analysis
            photo_settings['focal_length'] = self._safe_get_exif_rational(exif_dict, 37386)  # FocalLength
            photo_settings['focal_length_35mm'] = self._safe_get_exif(exif_dict, 41989, None)  # FocalLengthIn35mmFilm
            photo_settings['iso'] = self._safe_get_exif(exif_dict, 34855, None)  # ISOSpeedRatings
            photo_settings['exposure_time'] = self._safe_get_exif_rational(exif_dict, 33434)  # ExposureTime
            photo_settings['f_number'] = self._safe_get_exif_rational(exif_dict, 33437)  # FNumber
            photo_settings['exposure_program'] = self._safe_get_exif(exif_dict, 34850, None)  # ExposureProgram
            photo_settings['metering_mode'] = self._safe_get_exif(exif_dict, 37383, None)  # MeteringMode
            photo_settings['flash'] = self._safe_get_exif(exif_dict, 37385, None)  # Flash
            
            # GPS data (if available - many phones don't include this)
            gps_info = {}
            gps_data = exif_dict.get(34853, {})  # GPSInfo
            if gps_data:
                gps_info['latitude'] = self._extract_gps_coord(gps_data, 'lat')
                gps_info['longitude'] = self._extract_gps_coord(gps_data, 'lon')
                gps_info['altitude'] = self._safe_get_gps_rational(gps_data, 6)  # GPSAltitude
                gps_info['timestamp'] = self._extract_gps_timestamp(gps_data)
                gps_info['direction'] = self._safe_get_gps_rational(gps_data, 17)  # GPSImgDirection
            
            # Image technical details
            technical = {}
            technical['width'] = self._safe_get_exif(exif_dict, 256, img.width)  # ImageWidth
            technical['height'] = self._safe_get_exif(exif_dict, 257, img.height)  # ImageLength
            technical['orientation'] = self._safe_get_exif(exif_dict, 274, 1)  # Orientation
            technical['resolution_x'] = self._safe_get_exif_rational(exif_dict, 282)  # XResolution
            technical['resolution_y'] = self._safe_get_exif_rational(exif_dict, 283)  # YResolution
            technical['color_space'] = self._safe_get_exif(exif_dict, 40961, None)  # ColorSpace
            
            # Compile only non-empty sections
            if any(v for v in camera_info.values() if v != 'Unknown'):
                exif_data['camera'] = camera_info
            if any(v for v in photo_settings.values() if v is not None):
                exif_data['photo'] = photo_settings
            if any(v for v in gps_info.values() if v is not None):
                exif_data['gps'] = gps_info
            if any(v for v in technical.values() if v is not None):
                exif_data['technical'] = technical
                
        except Exception as e:
            logger.debug(f"EXIF extraction failed gracefully: {e}")
            # Don't log as error - many images simply don't have EXIF
            
        return exif_data
    
    def _safe_get_exif(self, exif_dict: dict, tag: int, default=None):
        """Safely get EXIF value with default"""
        try:
            value = exif_dict.get(tag)
            return value if value is not None else default
        except:
            return default
    
    def _safe_get_exif_rational(self, exif_dict: dict, tag: int) -> float:
        """Safely get EXIF rational value as float"""
        try:
            value = exif_dict.get(tag)
            if value and hasattr(value, 'numerator') and hasattr(value, 'denominator'):
                return float(value.numerator) / float(value.denominator) if value.denominator != 0 else None
            return None
        except:
            return None
    
    def _safe_get_gps_rational(self, gps_dict: dict, tag: int) -> float:
        """Safely get GPS rational value"""
        try:
            value = gps_dict.get(tag)
            if value and hasattr(value, 'numerator') and hasattr(value, 'denominator'):
                return float(value.numerator) / float(value.denominator) if value.denominator != 0 else None
            return None
        except:
            return None
    
    def _extract_gps_coord(self, gps_data: dict, coord_type: str) -> float:
        """Extract GPS coordinates handling different phone formats"""
        try:
            if coord_type == 'lat':
                coord = gps_data.get(2)  # GPSLatitude
                ref = gps_data.get(1, 'N')  # GPSLatitudeRef
            else:  # longitude
                coord = gps_data.get(4)  # GPSLongitude  
                ref = gps_data.get(3, 'E')  # GPSLongitudeRef
                
            if not coord:
                return None
                
            # Convert DMS to decimal degrees
            if isinstance(coord, (list, tuple)) and len(coord) >= 3:
                degrees = float(coord[0].numerator) / float(coord[0].denominator)
                minutes = float(coord[1].numerator) / float(coord[1].denominator)
                seconds = float(coord[2].numerator) / float(coord[2].denominator)
                decimal = degrees + (minutes / 60.0) + (seconds / 3600.0)
                
                # Apply hemisphere
                if ref in ['S', 'W']:
                    decimal = -decimal
                    
                return decimal
        except:
            pass
        return None
    
    def _extract_gps_timestamp(self, gps_data: dict) -> str:
        """Extract GPS timestamp if available"""
        try:
            date_stamp = gps_data.get(29)  # GPSDateStamp
            time_stamp = gps_data.get(7)   # GPSTimeStamp
            
            if date_stamp and time_stamp:
                if isinstance(time_stamp, (list, tuple)) and len(time_stamp) >= 3:
                    hours = int(float(time_stamp[0].numerator) / float(time_stamp[0].denominator))
                    minutes = int(float(time_stamp[1].numerator) / float(time_stamp[1].denominator))
                    seconds = int(float(time_stamp[2].numerator) / float(time_stamp[2].denominator))
                    return f"{date_stamp} {hours:02d}:{minutes:02d}:{seconds:02d}"
        except:
            pass
        return None

    def _get_original_urls(self, file_path: Path, alert_id: str) -> Dict[str, str]:
        """Return original URLs when processing fails"""
        original_url = f'https://api.ufobeep.com/media/{alert_id}/{file_path.name}'
        return {
            'original': original_url,
            'thumbnail': original_url,
            'web': original_url,
            'preview': original_url
        }
    
    @staticmethod
    def check_ffmpeg_available() -> bool:
        """Check if ffmpeg is available for video processing"""
        try:
            subprocess.run(['ffmpeg', '-version'], capture_output=True, timeout=5)
            return True
        except (subprocess.TimeoutExpired, FileNotFoundError):
            return False