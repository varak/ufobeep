import os
from enum import Enum
from typing import List, Optional, Any
try:
    from pydantic_settings import BaseSettings, SettingsConfigDict
    from pydantic import Field, field_validator
except ImportError:
    # Fallback for older pydantic versions
    from pydantic import BaseSettings, Field, validator as field_validator


class Environment(str, Enum):
    DEVELOPMENT = "development"
    STAGING = "staging"
    PRODUCTION = "production"


class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # === Application Settings ===
    app_name: str = Field(default="UFOBeep API", env="APP_NAME")
    app_version: str = Field(default="0.1.0", env="APP_VERSION")
    environment: Environment = Field(default=Environment.DEVELOPMENT, env="ENVIRONMENT")
    debug: bool = Field(default=True, env="DEBUG")
    
    # === Server Configuration ===
    host: str = Field(default="0.0.0.0", env="HOST")
    port: int = Field(default=8000, env="PORT")
    workers: int = Field(default=1, env="WORKERS")
    reload: bool = Field(default=True, env="RELOAD")
    
    # === API Configuration ===
    api_version: str = Field(default="v1", env="API_VERSION")
    api_prefix: str = Field(default="/v1", env="API_PREFIX")
    
    # === Matrix Configuration ===
    matrix_base_url: str = Field(env="MATRIX_BASE_URL")
    matrix_server_name: str = Field(env="MATRIX_SERVER_NAME")
    matrix_access_token: str = Field(env="MATRIX_ACCESS_TOKEN")
    matrix_bot_user_id: str = Field(env="MATRIX_BOT_USER_ID")
    
    # === Database Configuration ===
    database_url: str = Field(env="DATABASE_URL")
    database_pool_size: int = Field(default=20, env="DATABASE_POOL_SIZE")
    database_max_overflow: int = Field(default=10, env="DATABASE_MAX_OVERFLOW")
    database_pool_timeout: int = Field(default=30, env="DATABASE_POOL_TIMEOUT")
    
    # === Redis Configuration ===
    redis_url: str = Field(env="REDIS_URL")
    redis_cache_ttl: int = Field(default=3600, env="REDIS_CACHE_TTL")
    
    # === Celery Configuration ===
    celery_broker_url: str = Field(env="CELERY_BROKER_URL")
    celery_result_backend: str = Field(env="CELERY_RESULT_BACKEND")
    
    # === Storage Configuration ===
    s3_endpoint: str = Field(env="S3_ENDPOINT")
    s3_bucket: str = Field(env="S3_BUCKET")
    s3_access_key: str = Field(env="S3_ACCESS_KEY")
    s3_secret_key: str = Field(env="S3_SECRET_KEY")
    s3_region: str = Field(default="us-east-1", env="S3_REGION")
    max_upload_size: int = Field(default=10485760, env="MAX_UPLOAD_SIZE")  # 10MB
    
    # === External APIs ===
    openweather_api_key: str = Field(env="OPENWEATHER_API_KEY")
    openweather_base_url: str = Field(
        default="https://api.openweathermap.org/data/2.5",
        env="OPENWEATHER_BASE_URL"
    )
    
    # === HuggingFace Configuration ===
    huggingface_api_token: Optional[str] = Field(default=None, env="HUGGINGFACE_API_TOKEN")
    huggingface_model_nsfw: str = Field(
        default="martin-ha/toxic-comment-model",
        env="HUGGINGFACE_MODEL_NSFW"
    )
    
    # === OpenSky Network Configuration ===
    opensky_client_id: str = Field(env="OPENSKY_CLIENT_ID")
    opensky_client_secret: str = Field(env="OPENSKY_CLIENT_SECRET")
    opensky_base_url: str = Field(
        default="https://opensky-network.org/api",
        env="OPENSKY_BASE_URL"
    )
    
    # === Plane Matching Configuration ===
    plane_match_enabled: bool = Field(default=True, env="PLANE_MATCH_ENABLED")
    plane_match_radius_km: float = Field(default=50.0, env="PLANE_MATCH_RADIUS_KM")  # Max 80km for free tier
    plane_match_tolerance_deg: float = Field(default=2.5, env="PLANE_MATCH_TOLERANCE_DEG")
    plane_match_cache_ttl: int = Field(default=10, env="PLANE_MATCH_CACHE_TTL")  # seconds
    plane_match_time_quantization: int = Field(default=5, env="PLANE_MATCH_TIME_QUANTIZATION")  # seconds
    
    # === Push Notifications ===
    fcm_server_key: str = Field(env="FCM_SERVER_KEY")
    apns_key_id: str = Field(env="APNS_KEY_ID")
    apns_team_id: str = Field(env="APNS_TEAM_ID")
    apns_bundle_id: str = Field(default="com.ufobeep.ufobeep", env="APNS_BUNDLE_ID")
    
    # === Security ===
    secret_key: str = Field(env="SECRET_KEY")
    jwt_secret: str = Field(env="JWT_SECRET")
    jwt_algorithm: str = Field(default="HS256", env="JWT_ALGORITHM")
    jwt_expiration_hours: int = Field(default=24, env="JWT_EXPIRATION_HOURS")
    encryption_key: str = Field(env="ENCRYPTION_KEY")
    cors_origins: str = Field(
        default="http://localhost:3000,http://localhost:3001",
        env="CORS_ORIGINS"
    )
    
    # === Rate Limiting ===
    rate_limit_per_minute: int = Field(default=60, env="RATE_LIMIT_PER_MINUTE")
    rate_limit_burst: int = Field(default=10, env="RATE_LIMIT_BURST")
    
    # === Logging ===
    log_level: str = Field(default="INFO", env="LOG_LEVEL")
    log_file: str = Field(default="logs/ufobeep.log", env="LOG_FILE")
    enable_access_logs: bool = Field(default=True, env="ENABLE_ACCESS_LOGS")
    
    # === Feature Flags ===
    enable_registration: bool = Field(default=True, env="ENABLE_REGISTRATION")
    enable_email_verification: bool = Field(default=False, env="ENABLE_EMAIL_VERIFICATION")
    enable_moderation: bool = Field(default=True, env="ENABLE_MODERATION")
    enable_analytics: bool = Field(default=False, env="ENABLE_ANALYTICS")
    
    # === Enrichment Settings ===
    enable_weather_enrichment: bool = Field(default=True, env="ENABLE_WEATHER_ENRICHMENT")
    enable_celestial_enrichment: bool = Field(default=True, env="ENABLE_CELESTIAL_ENRICHMENT")
    enable_satellite_enrichment: bool = Field(default=True, env="ENABLE_SATELLITE_ENRICHMENT")
    enable_hf_nsfw_filter: bool = Field(default=True, env="ENABLE_HF_NSFW_FILTER")
    enrichment_timeout: int = Field(default=30, env="ENRICHMENT_TIMEOUT")
    
    # === Coordinates Jittering ===
    public_coord_jitter_min: int = Field(default=100, env="PUBLIC_COORD_JITTER_MIN")  # meters
    public_coord_jitter_max: int = Field(default=300, env="PUBLIC_COORD_JITTER_MAX")  # meters
    
    # === Locale Configuration ===
    default_locale: str = Field(default="en", env="DEFAULT_LOCALE")
    supported_locales: str = Field(default="en,es,de", env="SUPPORTED_LOCALES")
    
    model_config = SettingsConfigDict(
        env_file="../.env",  # Look in parent directory for main .env file
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"  # Ignore extra fields in .env file
    )
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Get CORS origins as a list"""
        return [x.strip() for x in self.cors_origins.split(',') if x.strip()]
    
    @property
    def supported_locales_list(self) -> List[str]:
        """Get supported locales as a list"""
        return [x.strip() for x in self.supported_locales.split(',') if x.strip()]
    
    # Property methods for computed values
    @property
    def is_development(self) -> bool:
        return self.environment == Environment.DEVELOPMENT
    
    @property
    def is_staging(self) -> bool:
        return self.environment == Environment.STAGING
    
    @property
    def is_production(self) -> bool:
        return self.environment == Environment.PRODUCTION
    
    @property
    def base_url(self) -> str:
        """Get the base URL for this API instance"""
        if self.is_production:
            return "https://api.ufobeep.com"
        elif self.is_staging:
            return "https://api-staging.ufobeep.com"
        else:
            return f"http://{self.host}:{self.port}"
    
    @property
    def full_api_url(self) -> str:
        """Get the full API URL with version prefix"""
        return f"{self.base_url}{self.api_prefix}"
    
    def log_configuration(self) -> None:
        """Log current configuration (without sensitive data)"""
        if self.debug:
            print("=== UFOBeep API Environment Configuration ===")
            print(f"Environment: {self.environment}")
            print(f"App Name: {self.app_name}")
            print(f"App Version: {self.app_version}")
            print(f"Base URL: {self.base_url}")
            print(f"API URL: {self.full_api_url}")
            print(f"Matrix Server: {self.matrix_server_name}")
            print(f"Debug Mode: {self.debug}")
            print(f"Default Locale: {self.default_locale}")
            print(f"Supported Locales: {', '.join(self.supported_locales)}")
            print(f"Database Pool Size: {self.database_pool_size}")
            print(f"Max Upload Size: {self.max_upload_size / (1024*1024):.1f}MB")
            print("============================================")


# Global settings instance
settings = Settings()

# Convenience function to get environment-specific values
def get_environment_value(dev_value: str, staging_value: str, prod_value: str) -> str:
    """Get a value based on current environment"""
    if settings.is_production:
        return prod_value
    elif settings.is_staging:
        return staging_value
    else:
        return dev_value