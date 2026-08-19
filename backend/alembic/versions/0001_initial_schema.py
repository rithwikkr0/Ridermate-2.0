\"\"\"initial schema

Revision ID: 0001
Revises: 
Create Date: 2026-08-19 12:00:00.000000

\"\"\"
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from app.models.models import Base

# revision identifiers, used by Alembic.
revision: str = '0001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    Base.metadata.create_all(bind=bind)


def downgrade() -> None:
    bind = op.get_bind()
    Base.metadata.drop_all(bind=bind)
