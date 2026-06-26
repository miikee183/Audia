import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Usuario(Base):
    __tablename__ = "usuarios"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    usuario: Mapped[str | None] = mapped_column(String(100), nullable=True)
    correo: Mapped[str] = mapped_column(String(255), unique=True, nullable=False)
    contrasena: Mapped[str | None] = mapped_column(String(255), nullable=True)
    telefono: Mapped[str] = mapped_column(String(20), nullable=False)
    auth_provider: Mapped[str] = mapped_column(String(20), default="email")
    personalizado: Mapped[bool] = mapped_column(default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    personalizacion: Mapped["Personalizacion | None"] = relationship(
        back_populates="usuario", uselist=False, cascade="all, delete-orphan"
    )
