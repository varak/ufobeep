import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration
import os

def init_sentry():
    """Initialize Sentry for error tracking and performance monitoring"""
    sentry_dsn = os.getenv('SENTRY_DSN')
    environment = os.getenv('ENVIRONMENT', 'development')

    if not sentry_dsn:
        print("Sentry DSN not configured, skipping initialization")
        return

    sentry_sdk.init(
        dsn=sentry_dsn,
        integrations=[
            FastApiIntegration(auto_enabling_integrations=True),
            SqlalchemyIntegration(),
        ],
        environment=environment,
        # Performance Monitoring
        traces_sample_rate=0.1 if environment == 'production' else 1.0,
        # Release tracking
        release=os.getenv('SENTRY_RELEASE'),
        # Error filtering
        before_send=lambda event, hint: event if environment != 'development' else None,
    )

    print(f"Sentry initialized for environment: {environment}")