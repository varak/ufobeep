"""Convert MagicLink to authorization code flow

Revision ID: magic_link_auth_code
Revises: device_id_column
Create Date: 2025-08-27

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'magic_link_auth_code'
down_revision = 'device_id_column'
branch_labels = None
depends_on = None


def upgrade():
    """Convert MagicLink from JWT-based to authorization code flow"""
    
    # Add new columns for authorization code flow
    op.add_column('magic_links', sa.Column('code', sa.String(64), nullable=True))
    op.add_column('magic_links', sa.Column('used_at', sa.DateTime(timezone=True), nullable=True))
    op.add_column('magic_links', sa.Column('used_by_device_id', sa.String(255), nullable=True))
    
    # Create unique index on code
    op.create_index('magic_links_code_ux', 'magic_links', ['code'], unique=True)
    
    # Drop old JWT-related columns and constraints
    op.drop_index('ix_magic_links_hashed_nonce', 'magic_links')
    op.drop_index('ix_magic_links_jti', 'magic_links') 
    op.drop_column('magic_links', 'hashed_nonce')
    op.drop_column('magic_links', 'jti')
    op.drop_column('magic_links', 'used')
    
    # Make code column required after data migration
    op.alter_column('magic_links', 'code', nullable=False)


def downgrade():
    """Revert to JWT-based magic link flow"""
    
    # Add back JWT columns
    op.add_column('magic_links', sa.Column('hashed_nonce', sa.String(255), nullable=False))
    op.add_column('magic_links', sa.Column('jti', sa.String(255), nullable=False))
    op.add_column('magic_links', sa.Column('used', sa.Boolean(), nullable=False, default=False))
    
    # Recreate JWT indexes
    op.create_index('ix_magic_links_hashed_nonce', 'magic_links', ['hashed_nonce'], unique=True)
    op.create_index('ix_magic_links_jti', 'magic_links', ['jti'], unique=True)
    
    # Drop authorization code columns and constraints
    op.drop_index('magic_links_code_ux', 'magic_links')
    op.drop_column('magic_links', 'code')
    op.drop_column('magic_links', 'used_at')
    op.drop_column('magic_links', 'used_by_device_id')