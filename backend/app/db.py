import psycopg2
from contextlib import contextmanager
from .config import settings

# Simple generator dependency for FastAPI to provide a DB connection per request
@contextmanager
def get_db():
    """Yield a PostgreSQL connection using the DATABASE_URL from settings.
    The connection is closed automatically after use.
    """
    conn = psycopg2.connect(settings.DATABASE_URL)
    try:
        yield conn
    finally:
        conn.close()
