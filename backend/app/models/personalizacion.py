import uuid
from sqlalchemy import String, ForeignKey, Text, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Personalizacion(Base):
    __tablename__ = "personalizacion"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    cuenta_id: Mapped[str] = mapped_column(String(36), ForeignKey("cuentas.id"), unique=True, nullable=False)
    
    ano_nacimiento: Mapped[int] = mapped_column(Integer, nullable=False)
    sexo: Mapped[str] = mapped_column(String(20), nullable=False)
    nombre_usuario: Mapped[str] = mapped_column(String(100), nullable=False)
    gustos: Mapped[str | None] = mapped_column(Text, nullable=True)
    foto_perfil: Mapped[str | None] = mapped_column(Text, nullable=True)
    idioma: Mapped[str] = mapped_column(String(50), nullable=False)

    cuenta: Mapped["Cuenta"] = relationship(back_populates="personalizacion")
