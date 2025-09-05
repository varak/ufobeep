"""
Admin Service - Clean business logic for admin operations
Extracts all admin database queries and business logic from HTTP endpoints
"""
import json
import asyncpg
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from dataclasses import dataclass

@dataclass 
class AdminStats:
    total_sightings: int
    total_media_files: int
    sightings_today: int
    sightings_this_week: int
    pending_sightings: int
    verified_sightings: int
    total_witness_confirmations: int
    confirmations_today: int
    database_size_mb: Optional[float] = None

@dataclass
class SightingAdmin:
    id: str
    title: Optional[str]
    description: Optional[str]
    category: str
    status: str
    created_at: datetime
    location_name: Optional[str]
    media_count: int
    witness_count: int

class AdminService:
    def __init__(self, db_pool):
        self.db_pool = db_pool
    
    async def get_dashboard_stats(self) -> AdminStats:
        """Get admin dashboard statistics"""
        async with self.db_pool.acquire() as conn:
            # Get basic counts
            total_sightings = await conn.fetchval("SELECT COUNT(*) FROM sightings") or 0
            sightings_today = await conn.fetchval("""
                SELECT COUNT(*) FROM sightings 
                WHERE created_at >= CURRENT_DATE
            """) or 0
            sightings_this_week = await conn.fetchval("""
                SELECT COUNT(*) FROM sightings 
                WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
            """) or 0
            
            # Get witness confirmations
            total_confirmations = await conn.fetchval("""
                SELECT COUNT(*) FROM witness_confirmations
            """) or 0
            confirmations_today = await conn.fetchval("""
                SELECT COUNT(*) FROM witness_confirmations 
                WHERE confirmed_at >= CURRENT_DATE
            """) or 0
            
            # Get database size
            try:
                db_size = await conn.fetchval("""
                    SELECT pg_size_pretty(pg_database_size(current_database()))
                """)
                # Extract MB value if possible
                if db_size and 'MB' in str(db_size):
                    size_mb = float(str(db_size).replace(' MB', ''))
                else:
                    size_mb = None
            except:
                size_mb = None
            
            return AdminStats(
                total_sightings=total_sightings,
                total_media_files=0,  # TODO: implement
                sightings_today=sightings_today,
                sightings_this_week=sightings_this_week,
                pending_sightings=0,  # TODO: implement
                verified_sightings=0,  # TODO: implement
                total_witness_confirmations=total_confirmations,
                confirmations_today=confirmations_today,
                database_size_mb=size_mb
            )
    
    async def get_recent_sightings(self, limit: int = 20) -> List[SightingAdmin]:
        """Get recent sightings for admin management"""
        async with self.db_pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT 
                    s.id::text, 
                    s.title, 
                    s.description, 
                    s.category, 
                    s.status,
                    s.created_at,
                    s.witness_count,
                    s.enrichment_data,
                    COALESCE(
                        (SELECT COUNT(*) FROM unnest(
                            CASE 
                                WHEN s.media_info::text != '{}' 
                                THEN COALESCE((s.media_info->'files')::jsonb, '[]'::jsonb)
                                ELSE '[]'::jsonb
                            END
                        )), 0
                    ) as media_count
                FROM sightings s
                ORDER BY s.created_at DESC 
                LIMIT $1
            """, limit)
            
            sightings = []
            for row in rows:
                # Extract location name from enrichment data
                location_name = "Unknown Location"
                if row['enrichment_data']:
                    try:
                        enrichment = row['enrichment_data']
                        if isinstance(enrichment, str):
                            enrichment = json.loads(enrichment)
                        if enrichment and 'location' in enrichment:
                            location_name = enrichment['location'].get('name', 'Unknown Location')
                    except:
                        pass
                
                sightings.append(SightingAdmin(
                    id=row['id'],
                    title=row['title'],
                    description=row['description'],
                    category=row['category'] or 'ufo',
                    status=row['status'] or 'created',
                    created_at=row['created_at'],
                    location_name=location_name,
                    media_count=row['media_count'] or 0,
                    witness_count=row['witness_count'] or 0
                ))
            
            return sightings
    
    async def delete_sighting(self, sighting_id: str) -> Dict[str, Any]:
        """Delete a sighting and all related data with comprehensive cleanup"""
        import os
        import shutil
        
        deleted_records = {}
        deleted_files = 0
        freed_bytes = 0
        
        async with self.db_pool.acquire() as conn:
            async with conn.transaction():
                # First, get media file paths for filesystem cleanup
                media_files = await conn.fetch("""
                    SELECT filename, url FROM media_files WHERE sighting_id = $1
                """, sighting_id)
                
                photo_files = await conn.fetch("""
                    SELECT file_path FROM photo_metadata WHERE sighting_id = $1
                """, sighting_id)
                
                # Delete from all related tables (order matters for foreign keys)
                related_tables = [
                    'media_files',
                    'comments', 
                    'follows',
                    'photo_metadata',
                    'photo_analysis_results',
                    'witness_confirmations'
                ]
                
                for table in related_tables:
                    try:
                        result = await conn.execute(f"""
                            DELETE FROM {table} WHERE sighting_id = $1
                        """, sighting_id)
                        count = int(result.split()[-1]) if result.split()[-1].isdigit() else 0
                        deleted_records[table] = count
                    except Exception as e:
                        deleted_records[table] = f"Error: {str(e)}"
                
                # Delete the main sighting record
                result = await conn.execute("""
                    DELETE FROM sightings WHERE id = $1
                """, sighting_id)
                sighting_deleted = "DELETE 1" in result
                
                # Clean up media files from filesystem
                MEDIA_BASE_PATH = '/home/ufobeep/ufobeep/media'  # Production media path
                
                # Clean individual media files
                for media_file in media_files:
                    filename = media_file['filename']
                    if filename:
                        file_path = os.path.join(MEDIA_BASE_PATH, str(sighting_id), filename)
                        if os.path.exists(file_path):
                            try:
                                file_size = os.path.getsize(file_path)
                                os.remove(file_path)
                                deleted_files += 1
                                freed_bytes += file_size
                            except Exception:
                                pass
                
                # Clean photo metadata files
                for photo_file in photo_files:
                    file_path = photo_file['file_path']
                    if file_path and os.path.exists(file_path):
                        try:
                            file_size = os.path.getsize(file_path)
                            os.remove(file_path)
                            deleted_files += 1
                            freed_bytes += file_size
                        except Exception:
                            pass
                
                # Remove sighting media directory if it exists
                media_dir = os.path.join(MEDIA_BASE_PATH, str(sighting_id))
                if os.path.exists(media_dir):
                    try:
                        # Calculate directory size before deletion
                        dir_size = sum(os.path.getsize(os.path.join(dirpath, filename))
                                     for dirpath, dirnames, filenames in os.walk(media_dir)
                                     for filename in filenames)
                        shutil.rmtree(media_dir)
                        freed_bytes += dir_size
                    except Exception:
                        pass
                
                return {
                    'success': sighting_deleted,
                    'sighting_id': sighting_id,
                    'deleted_records': deleted_records,
                    'deleted_files': deleted_files,
                    'freed_bytes': freed_bytes,
                    'freed_mb': round(freed_bytes / (1024 * 1024), 2) if freed_bytes > 0 else 0
                }
    
    async def delete_sightings_by_reporter(self, reporter_id: str) -> Dict[str, Any]:
        """Delete all sightings from a specific reporter with comprehensive cleanup"""
        async with self.db_pool.acquire() as conn:
            # First get all sighting IDs for this reporter
            sighting_records = await conn.fetch("""
                SELECT id::text, title FROM sightings WHERE reporter_id = $1
            """, reporter_id)
            
            if not sighting_records:
                return {
                    'success': True,
                    'message': f'No sightings found for reporter {reporter_id}',
                    'deleted_count': 0,
                    'deleted_records': {},
                    'deleted_files': 0,
                    'freed_bytes': 0,
                    'freed_mb': 0
                }
            
            sighting_ids = [record['id'] for record in sighting_records]
            
            # Delete each sighting using the comprehensive delete method
            total_deleted_records = {}
            total_deleted_files = 0
            total_freed_bytes = 0
            successfully_deleted = 0
            
            for sighting_id in sighting_ids:
                try:
                    result = await self.delete_sighting(sighting_id)
                    if result['success']:
                        successfully_deleted += 1
                        total_deleted_files += result['deleted_files']
                        total_freed_bytes += result['freed_bytes']
                        
                        # Aggregate deleted records counts
                        for table, count in result['deleted_records'].items():
                            if isinstance(count, int):
                                total_deleted_records[table] = total_deleted_records.get(table, 0) + count
                            else:
                                total_deleted_records[table] = count
                                
                except Exception as e:
                    # Continue with other sightings even if one fails
                    total_deleted_records[f'error_{sighting_id}'] = str(e)
            
            return {
                'success': True,
                'reporter_id': reporter_id,
                'found_sightings': len(sighting_ids),
                'deleted_count': successfully_deleted,
                'deleted_records': total_deleted_records,
                'deleted_files': total_deleted_files,
                'freed_bytes': total_freed_bytes,
                'freed_mb': round(total_freed_bytes / (1024 * 1024), 2) if total_freed_bytes > 0 else 0
            }
    
    async def verify_sighting(self, sighting_id: str) -> bool:
        """Mark sighting as verified"""
        async with self.db_pool.acquire() as conn:
            result = await conn.execute("""
                UPDATE sightings 
                SET status = 'verified', updated_at = NOW()
                WHERE id = $1
            """, sighting_id)
            
            return "UPDATE 1" in result
    
    async def get_all_sightings(self, limit: int = 50, offset: int = 0) -> List[SightingAdmin]:
        """Get all sightings for admin management with pagination"""
        async with self.db_pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT 
                    s.id::text, 
                    s.title, 
                    s.description, 
                    s.category, 
                    s.status,
                    s.alert_level,
                    s.created_at,
                    s.witness_count,
                    s.enrichment_data,
                    s.media_info,
                    COALESCE(
                        (SELECT COUNT(*) FROM unnest(
                            CASE 
                                WHEN s.media_info::text != '{}' 
                                THEN COALESCE((s.media_info->'files')::jsonb, '[]'::jsonb)
                                ELSE '[]'::jsonb
                            END
                        )), 0
                    ) as media_count
                FROM sightings s
                ORDER BY s.created_at DESC 
                LIMIT $1 OFFSET $2
            """, limit, offset)
            
            sightings = []
            for row in rows:
                # Extract location name from enrichment data
                location_name = "Unknown Location"
                if row['enrichment_data']:
                    try:
                        enrichment = row['enrichment_data']
                        if isinstance(enrichment, str):
                            enrichment = json.loads(enrichment)
                        if enrichment and 'location' in enrichment:
                            location_name = enrichment['location'].get('name', 'Unknown Location')
                    except:
                        pass
                
                sightings.append(SightingAdmin(
                    id=row['id'],
                    title=row['title'] or 'Untitled',
                    description=(row['description'] or '')[:100] + '...' if row['description'] and len(row['description']) > 100 else row['description'] or '',
                    category=row['category'] or 'ufo',
                    status=row['status'] or 'created',
                    created_at=row['created_at'],
                    location_name=location_name,
                    media_count=row['media_count'] or 0,
                    witness_count=row['witness_count'] or 0
                ))
            
            return sightings
    
    async def get_sighting_count(self) -> int:
        """Get total sighting count for pagination"""
        async with self.db_pool.acquire() as conn:
            return await conn.fetchval("SELECT COUNT(*) FROM sightings") or 0