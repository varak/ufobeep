"""
Request Middleware - MP14
Proper error handling and request timeouts for production
"""

import asyncio
import time
import logging
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from typing import Callable

logger = logging.getLogger(__name__)

class RequestTimeoutMiddleware(BaseHTTPMiddleware):
    """Middleware to handle request timeouts and malformed requests"""
    
    def __init__(self, app, timeout_seconds: int = 30):
        super().__init__(app)
        self.timeout_seconds = timeout_seconds
    
    async def dispatch(self, request: Request, call_next: Callable):
        start_time = time.time()
        
        try:
            # Set a timeout for the request
            response = await asyncio.wait_for(
                call_next(request),
                timeout=self.timeout_seconds
            )
            
            # Log slow requests
            process_time = time.time() - start_time
            if process_time > 5.0:  # Log requests taking more than 5 seconds
                logger.warning(
                    f"Slow request: {request.method} {request.url.path} "
                    f"took {process_time:.2f}s"
                )
            
            return response
            
        except asyncio.TimeoutError:
            process_time = time.time() - start_time
            logger.error(
                f"Request timeout: {request.method} {request.url.path} "
                f"exceeded {self.timeout_seconds}s timeout"
            )
            return JSONResponse(
                status_code=504,
                content={
                    "detail": f"Request timed out after {self.timeout_seconds} seconds",
                    "error_type": "timeout_error",
                    "path": str(request.url.path)
                }
            )
        
        except Exception as e:
            process_time = time.time() - start_time
            logger.error(
                f"Request error: {request.method} {request.url.path} "
                f"failed after {process_time:.2f}s: {str(e)}"
            )
            
            # Don't expose internal errors in production
            if "pool is closed" in str(e):
                return JSONResponse(
                    status_code=503,
                    content={
                        "detail": "Database temporarily unavailable. Please try again.",
                        "error_type": "database_error",
                        "path": str(request.url.path)
                    }
                )
            
            # Re-raise other exceptions to be handled by FastAPI
            raise


class ErrorHandlingMiddleware(BaseHTTPMiddleware):
    """Middleware to handle JSON parsing and validation errors"""
    
    async def dispatch(self, request: Request, call_next: Callable):
        try:
            return await call_next(request)
        
        except Exception as e:
            error_message = str(e)
            
            # Handle JSON parsing errors
            if "JSON decode error" in error_message or "Unterminated string" in error_message:
                logger.warning(f"JSON parsing error for {request.url.path}: {error_message}")
                return JSONResponse(
                    status_code=400,
                    content={
                        "detail": "Invalid JSON format in request body",
                        "error_type": "json_parse_error",
                        "path": str(request.url.path)
                    }
                )
            
            # Handle database connection errors
            if "connection" in error_message.lower() and ("refused" in error_message or "timeout" in error_message):
                logger.error(f"Database connection error: {error_message}")
                return JSONResponse(
                    status_code=503,
                    content={
                        "detail": "Database connection failed. Please try again.",
                        "error_type": "database_connection_error", 
                        "path": str(request.url.path)
                    }
                )
            
            # Re-raise other exceptions
            raise