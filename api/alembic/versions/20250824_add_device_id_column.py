"""Add device_id column to users table

Revision ID: device_id_column
Revises: phone_verifications
Create Date: 2025-08-24

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'device_id_column'
down_revision = 'phone_verifications'
branch_labels = None
depends_on = None


def upgrade():
    """Add device_id column and unique index"""
    # Add device_id column
    op.add_column('users', sa.Column('device_id', sa.String(255), nullable=True))
    
    # Create unique index on device_id
    op.create_index('users_device_id_ux', 'users', ['device_id'], unique=True)


def downgrade():
    """Remove device_id column and index"""
    op.drop_index('users_device_id_ux', 'users')
    op.drop_column('users', 'device_id')