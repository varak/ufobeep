"""
User Data Models for Marketing and Analytics
"""

from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID, INET, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.database import Base

class EmailMarketing(Base):
    """GDPR-compliant email marketing consent tracking"""
    __tablename__ = "email_marketing"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='CASCADE'))
    consent_given_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    consent_source = Column(String(50))  # 'google_signin', 'magic_link', 'manual'
    unsubscribed_at = Column(DateTime(timezone=True))
    unsubscribe_reason = Column(String(255))
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    updated_at = Column(DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship to User
    user = relationship("User", back_populates="email_marketing")

class AnalyticsEvent(Base):
    """User behavior and interaction tracking"""
    __tablename__ = "analytics_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.id', ondelete='SET NULL'))
    event_type = Column(String(50), nullable=False)
    event_data = Column(JSONB)
    session_id = Column(String(100))
    device_id = Column(String(255))
    ip_address = Column(INET)
    user_agent = Column(Text)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    # Relationship to User
    user = relationship("User", back_populates="analytics_events")