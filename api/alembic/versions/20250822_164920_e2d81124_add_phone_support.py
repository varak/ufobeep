"""Add phone support for SMS authentication

Revision ID: e2d81124
Revises: 
Create Date: 2025-08-22 16:49:20

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'e2d81124'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    """Add phone number columns to users table"""
    # Add phone columns
    op.add_column('users', sa.Column('phone', sa.String(20), nullable=True))
    op.add_column('users', sa.Column('phone_verified', sa.Boolean(), default=False, nullable=False, server_default='false'))
    
    # Create index on phone for faster lookups
    op.create_index('ix_users_phone', 'users', ['phone'])


def downgrade():
    """Remove phone number columns"""
    op.drop_index('ix_users_phone', 'users')
    op.drop_column('users', 'phone_verified')
    op.drop_column('users', 'phone')