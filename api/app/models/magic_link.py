from sqlalchemy import Column, String, DateTime, Boolean, Integer
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from datetime import datetime
import uuid
from .sighting import Base


class MagicLink(Base):
    __tablename__ = "magic_links"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), nullable=False, index=True)
    hashed_nonce = Column(String(255), nullable=False, unique=True, index=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    used = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    user_agent = Column(String(500))
    ip_address = Column(String(45))
    
    def __repr__(self):
        return f"<MagicLink(email='{self.email}', used={self.used}, expires_at='{self.expires_at}')>"
    
    @property
    def is_expired(self):
        from datetime import datetime, timezone
        return datetime.now(timezone.utc) > self.expires_at
    
    @property
    def is_valid(self):
        return not self.used and not self.is_expired


class MagicLinkAttempt(Base):
    __tablename__ = "magic_link_attempts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), nullable=False, index=True)
    ip_address = Column(String(45), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    success = Column(Boolean, default=False)
    
    def __repr__(self):
        return f"<MagicLinkAttempt(email='{self.email}', ip='{self.ip_address}', success={self.success})>"