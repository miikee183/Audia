from app.database.database import Base, engine


def drop_tables():
    """Drop audios and comentarios so they get recreated with the new schema."""
    with engine.connect() as conn:
        conn.exec_driver_sql('DROP TABLE IF EXISTS "comentarios" CASCADE')
        conn.exec_driver_sql('DROP TABLE IF EXISTS "audios" CASCADE')
        conn.commit()
    Base.metadata.create_all(bind=engine)
