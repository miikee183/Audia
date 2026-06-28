from sqlalchemy import inspect, text
from app.database.database import engine


def _rename_column(table: str, old: str, new: str):
    inspector = inspect(engine)
    columns = [c["name"] for c in inspector.get_columns(table)]
    if old in columns and new not in columns:
        with engine.connect() as conn:
            conn.execute(text(f'ALTER TABLE "{table}" RENAME COLUMN "{old}" TO "{new}"'))
            conn.commit()
            print(f"Migrated {table}: {old} -> {new}")


def run_migrations():
    _rename_column("audios", "id_cuenta_dueno", "id_perfil_dueno")
    _rename_column("audios", "lista_likes_cuentas", "lista_likes_perfiles")
    _rename_column("comentarios", "id_dueno_comentario", "id_perfil_dueno_comentario")
    _rename_column("comentarios", "lista_likes_cuentas", "lista_likes_perfiles")
