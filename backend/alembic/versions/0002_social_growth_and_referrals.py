"""social growth, referrals, and phone hash

Revision ID: 0002
Revises: 0001
Create Date: 2026-08-19 12:56:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
import random
import string

# revision identifiers, used by Alembic.
revision: str = '0002'
down_revision: Union[str, None] = '0001'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()

    # 1. Add columns to users table if not exist
    try:
        op.add_column('users', sa.Column('phone_hash', sa.String(), nullable=True, server_default=''))
    except Exception:
        pass

    try:
        op.add_column('users', sa.Column('referral_code', sa.String(), nullable=True))
    except Exception:
        pass

    try:
        op.add_column('users', sa.Column('referred_by', sa.String(), sa.ForeignKey('users.id'), nullable=True))
    except Exception:
        pass

    # 2. Backfill unique referral codes for any existing users without a referral code
    try:
        result = conn.execute(sa.text(\"SELECT id FROM users WHERE referral_code IS NULL OR referral_code = ''\"))
        for row in result:
            user_id = row[0]
            code = 'RM-' + ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
            conn.execute(sa.text(\"UPDATE users SET referral_code = :code WHERE id = :uid\"), {\"code\": code, \"uid\": user_id})
    except Exception:
        pass

    # 3. Create indices
    try:
        op.create_index('ix_users_phone_hash', 'users', ['phone_hash'])
    except Exception:
        pass

    try:
        op.create_index('ix_users_referral_code', 'users', ['referral_code'], unique=True)
    except Exception:
        pass

    # 4. Create referrals table
    try:
        op.create_table(
            'referrals',
            sa.Column('id', sa.String(), primary_key=True),
            sa.Column('referrer_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), index=True, nullable=False),
            sa.Column('referred_id', sa.String(), sa.ForeignKey('users.id', ondelete='CASCADE'), unique=True, index=True, nullable=False),
            sa.Column('referral_code', sa.String(), nullable=False),
            sa.Column('status', sa.String(), server_default='converted', nullable=False),
            sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        )
    except Exception:
        pass


def downgrade() -> None:
    try:
        op.drop_table('referrals')
    except Exception:
        pass
    try:
        op.drop_index('ix_users_referral_code', table_name='users')
    except Exception:
        pass
    try:
        op.drop_index('ix_users_phone_hash', table_name='users')
    except Exception:
        pass
    try:
        op.drop_column('users', 'referred_by')
    except Exception:
        pass
    try:
        op.drop_column('users', 'referral_code')
    except Exception:
        pass
    try:
        op.drop_column('users', 'phone_hash')
    except Exception:
        pass
