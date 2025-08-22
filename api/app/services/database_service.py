"""
Database Service - MP14
Proper connection pool management for production
"""

import asyncpg
import logging
from typing import Optional

logger = logging.getLogger(__name__)

class DatabaseService:
    """Singleton database service with proper connection pool management"""
    
    _instance: Optional['DatabaseService'] = None
    _pool: Optional[asyncpg.Pool] = None
    
    def __new__(cls) -> 'DatabaseService':
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    async def initialize_pool(
        self, 
        host: str = "localhost",
        port: int = 5432,
        user: str = "ufobeep_user",
        password: str = "ufopostpass",
        database: str = "ufobeep_db",
        min_size: int = 2,
        max_size: int = 20,
        command_timeout: int = 60,
        server_settings: dict = None
    ) -> None:
        """Initialize the connection pool with production settings"""
        if self._pool is not None:
            logger.warning("Database pool already initialized")
            return
            
        try:
            # Production-ready pool settings
            self._pool = await asyncpg.create_pool(
                host=host,
                port=port,
                user=user,
                password=password,
                database=database,
                min_size=min_size,
                max_size=max_size,
                command_timeout=command_timeout,
                server_settings=server_settings or {
                    'jit': 'off',  # Disable JIT for faster connection times
                    'application_name': 'ufobeep_api'
                },
                # Connection lifetime and health checks
                max_inactive_connection_lifetime=300.0,  # 5 minutes
                setup=self._setup_connection
            )
            logger.info(f"Database pool initialized: {min_size}-{max_size} connections")
        except Exception as e:
            logger.error(f"Failed to initialize database pool: {e}")
            raise
    
    async def _setup_connection(self, connection: asyncpg.Connection) -> None:
        """Setup function called for each new connection"""
        # Set connection-level settings for better performance
        await connection.execute("SET timezone = 'UTC'")
        await connection.execute("SET statement_timeout = '30s'")
    
    @property
    def pool(self) -> asyncpg.Pool:
        """Get the database connection pool"""
        if self._pool is None:
            raise RuntimeError("Database pool not initialized. Call initialize_pool() first.")
        return self._pool
    
    async def close(self) -> None:
        """Close the database connection pool"""
        if self._pool is not None:
            await self._pool.close()
            self._pool = None
            logger.info("Database pool closed")
    
    async def health_check(self) -> dict:
        """Check database pool health"""
        if self._pool is None:
            return {"healthy": False, "error": "Pool not initialized"}
        
        try:
            async with self._pool.acquire() as conn:
                await conn.fetchval("SELECT 1")
                
            return {
                "healthy": True,
                "pool_size": self._pool.get_size(),
                "idle_connections": self._pool.get_idle_size(),
                "max_size": self._pool.get_max_size(),
                "min_size": self._pool.get_min_size()
            }
        except Exception as e:
            return {"healthy": False, "error": str(e)}

# Global instance
database_service = DatabaseService()

async def get_database_pool() -> asyncpg.Pool:
    """FastAPI dependency to get database pool"""
    return database_service.pool

def get_database_service() -> DatabaseService:
    """Get the database service instance"""
    return database_service