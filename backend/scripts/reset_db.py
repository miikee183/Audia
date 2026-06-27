import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL no está configurada en el archivo .env")
    sys.exit(1)

engine = create_engine(DATABASE_URL)

TABLES = ["codigos_verificacion", "personalizacion", "cuentas"]

def confirm():
    print("⚠️  Esto borrará TODOS los datos de las tablas:")
    for t in TABLES:
        print(f"  - {t}")
    print()
    response = input("¿Estás seguro? Escribe 'BORRAR' para confirmar: ")
    if response != "BORRAR":
        print("Cancelado.")
        sys.exit(0)

def reset():
    with engine.connect() as conn:
        for table in TABLES:
            print(f"  Borrando {table}...")
            conn.execute(text(f"TRUNCATE TABLE {table} CASCADE;"))
        conn.commit()
    print("✅ Datos borrados. Las tablas siguen intactas.")

if __name__ == "__main__":
    confirm()
    reset()
