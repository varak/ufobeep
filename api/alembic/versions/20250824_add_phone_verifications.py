"""Add phone_verifications table for SMS verification

Revision ID: phone_verifications
Revises: e2d81124
Create Date: 2025-08-24

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import DateTime

# revision identifiers, used by Alembic.
revision = 'phone_verifications'
down_revision = 'e2d81124'
branch_labels = None
depends_on = None


def upgrade():
    """Create phone_verifications table"""
    op.create_table(
        'phone_verifications',
        sa.Column('id', sa.Integer, primary_key=True, autoincrement=True),
        sa.Column('device_id', sa.String(255), nullable=False, unique=True),
        sa.Column('phone', sa.String(20), nullable=False),
        sa.Column('code', sa.String(10), nullable=False),
        sa.Column('created_at', DateTime, nullable=False),
        sa.Column('expires_at', DateTime, nullable=False),
        sa.Column('verified', sa.Boolean, default=False, nullable=False),
        sa.Column('verified_at', DateTime, nullable=True),
    )
    
    # Create indexes for faster lookups
    op.create_index('ix_phone_verifications_device_id', 'phone_verifications', ['device_id'])
    op.create_index('ix_phone_verifications_phone', 'phone_verifications', ['phone'])
    op.create_index('ix_phone_verifications_code', 'phone_verifications', ['code'])


def downgrade():
    """Drop phone_verifications table"""
    op.drop_index('ix_phone_verifications_code', 'phone_verifications')
    op.drop_index('ix_phone_verifications_phone', 'phone_verifications')
    op.drop_index('ix_phone_verifications_device_id', 'phone_verifications')
    op.drop_table('phone_verifications')