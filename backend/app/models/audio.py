import uuid
from datetime import datetime
from sqlalchemy import String, ForeignKey, Float, Boolean, DateTime, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Audio(Base):
    __tablename__ = "audios"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("cuentas.id"), nullable=False)
    cloudinary_url: Mapped[str] = mapped_column(String(512), nullable=False)
    cloudinary_public_id: Mapped[str] = mapped_column(String(256), nullable=True)
    duration: Mapped[float] = mapped_column(Float, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    user: Mapped["Cuenta"] = relationship(back_populates="audios")
    likes: Mapped[list["AudioLike"]] = relationship(back_populates="audio", cascade="all, delete-orphan")
    comments: Mapped[list["AudioComment"]] = relationship(back_populates="audio", cascade="all, delete-orphan")
    listens: Mapped[list["AudioListen"]] = relationship(back_populates="audio", cascade="all, delete-orphan")


class AudioLike(Base):
    __tablename__ = "audio_likes"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("cuentas.id"), nullable=False)
    audio_id: Mapped[str] = mapped_column(String(36), ForeignKey("audios.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    user: Mapped["Cuenta"] = relationship()
    audio: Mapped["Audio"] = relationship(back_populates="likes")

    __table_args__ = (UniqueConstraint("user_id", "audio_id", name="uq_user_audio_like"),)


class AudioComment(Base):
    __tablename__ = "audio_comments"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("cuentas.id"), nullable=False)
    audio_id: Mapped[str] = mapped_column(String(36), ForeignKey("audios.id"), nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    user: Mapped["Cuenta"] = relationship()
    audio: Mapped["Audio"] = relationship(back_populates="comments")


class AudioListen(Base):
    __tablename__ = "audio_listens"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("cuentas.id"), nullable=False)
    audio_id: Mapped[str] = mapped_column(String(36), ForeignKey("audios.id"), nullable=False)
    progress_seconds: Mapped[float] = mapped_column(Float, default=0.0)
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now, onupdate=datetime.now)

    user: Mapped["Cuenta"] = relationship()
    audio: Mapped["Audio"] = relationship(back_populates="listens")

    __table_args__ = (UniqueConstraint("user_id", "audio_id", name="uq_user_audio_listen"),)
