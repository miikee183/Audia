import uuid
from sqlalchemy import String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Cuenta(Base):
    __tablename__ = "cuentas"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    telefono: Mapped[str | None] = mapped_column(String(20), unique=True, nullable=True)
    correoGoogle: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    correoAudia: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    contrasenaAudia: Mapped[str | None] = mapped_column(String(255), nullable=True)

    id_perfil: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("perfiles.id"), unique=True, nullable=True
    )

    perfil: Mapped["Perfil | None"] = relationship(
        back_populates="cuenta", uselist=False, single_parent=True,
        foreign_keys=[id_perfil],
    )
    audios: Mapped[list["Audio"]] = relationship(
        back_populates="dueno", cascade="all, delete-orphan"
    )
    comentarios: Mapped[list["Comentario"]] = relationship(
        back_populates="dueno", cascade="all, delete-orphan"
    )
