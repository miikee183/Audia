import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Cuenta(Base):
    __tablename__ = "cuentas"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    telefono: Mapped[str | None] = mapped_column(String(20), unique=True, nullable=True)
    correoGoogle: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    correoAudia: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    contrasenaAudia: Mapped[str | None] = mapped_column(String(255), nullable=True)
    personalizado: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    personalizacion: Mapped["Personalizacion | None"] = relationship(
        back_populates="cuenta", uselist=False, cascade="all, delete-orphan"
    )
    audios: Mapped[list["Audio"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
