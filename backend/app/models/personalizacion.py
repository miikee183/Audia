import uuid
from datetime import date
from sqlalchemy import String, Text, Date, Integer, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Perfil(Base):
    __tablename__ = "perfiles"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))

    fecha_nacimiento: Mapped[date] = mapped_column(Date, nullable=False)
    sexo: Mapped[str] = mapped_column(String(20), nullable=False)
    nombre_usuario: Mapped[str] = mapped_column(String(100), nullable=False)
    foto_perfil: Mapped[str | None] = mapped_column(Text, nullable=True)
    biografia: Mapped[str | None] = mapped_column(Text, nullable=True)
    idioma: Mapped[str] = mapped_column(String(50), nullable=False)

    num_seguidores: Mapped[int] = mapped_column(Integer, default=0)
    num_siguiendo: Mapped[int] = mapped_column(Integer, default=0)
    likes_totales: Mapped[int] = mapped_column(Integer, default=0)

    lista_seguidores: Mapped[list] = mapped_column(JSON, default=list)
    lista_siguiendo: Mapped[list] = mapped_column(JSON, default=list)

    audios: Mapped[list["Audio"]] = relationship(
        back_populates="dueno", cascade="all, delete-orphan"
    )
    comentarios: Mapped[list["Comentario"]] = relationship(
        back_populates="dueno", cascade="all, delete-orphan"
    )

    cuenta: Mapped["Cuenta"] = relationship(back_populates="perfil", uselist=False)
