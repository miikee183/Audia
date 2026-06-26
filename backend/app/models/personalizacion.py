import uuid
from sqlalchemy import String, ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.database import Base


class Personalizacion(Base):
    __tablename__ = "personalizacion"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    usuario_id: Mapped[str] = mapped_column(String(36), ForeignKey("usuarios.id"), unique=True, nullable=False)
    username: Mapped[str] = mapped_column(String(100), nullable=False)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    idiomas: Mapped[str] = mapped_column(String(255), nullable=False)

    usuario: Mapped["Usuario"] = relationship(back_populates="personalizacion")
