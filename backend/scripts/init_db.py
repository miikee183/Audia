"""Drop all tables and recreate them with the current schema."""
from app.database.database import Base, engine

# Import all models so they register with Base.metadata
import app.models.cuenta  # noqa: F401
import app.models.personalizacion  # noqa: F401
import app.models.codigo_verificacion  # noqa: F401
import app.models.audio  # noqa: F401


def main():
    print("Dropping all tables...")
    Base.metadata.drop_all(bind=engine)
    print("Creating all tables...")
    Base.metadata.create_all(bind=engine)
    print("Done!")


if __name__ == "__main__":
    main()
