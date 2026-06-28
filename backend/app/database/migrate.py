from sqlalchemy import inspect, text
from app.database.database import Base, engine


def reset_all_tables(force: bool = False):
    """Drop entire public schema and recreate all tables (one-time migration)."""
    if not force:
        inspector = inspect(engine)
        try:
            columns = [c["name"] for c in inspector.get_columns("audios")]
            if "id_perfil_dueno" in columns:
                return  # already migrated
        except Exception:
            pass  # table might not exist yet

    with engine.connect() as conn:
        conn.execute(text("DROP SCHEMA public CASCADE"))
        conn.execute(text("CREATE SCHEMA public"))
        conn.commit()
    Base.metadata.create_all(bind=engine)
