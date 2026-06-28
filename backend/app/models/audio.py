import uuid
from sqlalchemy import String, ForeignKey, Float, Text, Integer, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Audio(Base):
    __tablename__ = "audios"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    id_perfil_dueno: Mapped[str] = mapped_column(String(36), ForeignKey("perfiles.id"), nullable=False)
    audio_url: Mapped[str] = mapped_column(String(512), nullable=False)
    duracion: Mapped[float] = mapped_column(Float, nullable=False)
    num_likes: Mapped[int] = mapped_column(Integer, default=0)
    num_comentarios: Mapped[int] = mapped_column(Integer, default=0)
    foto_fondo: Mapped[str | None] = mapped_column(Text, nullable=True)
    lista_likes_perfiles: Mapped[list] = mapped_column(JSON, default=list)

    dueno: Mapped["Perfil"] = relationship(back_populates="audios")
    comentarios: Mapped[list["Comentario"]] = relationship(back_populates="audio", cascade="all, delete-orphan")


class Comentario(Base):
    __tablename__ = "comentarios"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    id_perfil_dueno_comentario: Mapped[str] = mapped_column(String(36), ForeignKey("perfiles.id"), nullable=False)
    id_audio: Mapped[str] = mapped_column(String(36), ForeignKey("audios.id"), nullable=False)
    texto: Mapped[str] = mapped_column(Text, nullable=False)
    num_likes: Mapped[int] = mapped_column(Integer, default=0)
    lista_likes_perfiles: Mapped[list] = mapped_column(JSON, default=list)

    dueno: Mapped["Perfil"] = relationship(back_populates="comentarios")
    audio: Mapped["Audio"] = relationship(back_populates="comentarios")
