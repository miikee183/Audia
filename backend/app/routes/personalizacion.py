from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.models.personalizacion import Perfil
from app.schemas.personalizacion import PerfilRequest
from app.services.auth_service import get_current_account
from typing import Optional


class PerfilBasico(BaseModel):
    perfil_id: str
    nombre_usuario: str
    foto_perfil: Optional[str] = None

    class Config:
        from_attributes = True


router = APIRouter(prefix="/perfil", tags=["perfil"])


@router.post("/")
def crear_perfil(request: PerfilRequest, db: Session = Depends(get_db)):
    cuenta = db.query(Cuenta).filter(Cuenta.id == request.cuenta_id).first()
    if not cuenta:
        raise HTTPException(status_code=404, detail="Cuenta no encontrada")

    if cuenta.perfil:
        raise HTTPException(status_code=400, detail="Esta cuenta ya tiene un perfil")

    perfil = Perfil(
        fecha_nacimiento=request.fecha_nacimiento,
        sexo=request.sexo,
        nombre_usuario=request.nombre_usuario,
        foto_perfil=request.foto_perfil,
        biografia=request.biografia,
        idioma=request.idioma,
    )
    db.add(perfil)
    db.flush()

    cuenta.id_perfil = perfil.id

    db.commit()
    db.refresh(perfil)

    return {"message": "Perfil creado con éxito", "id": perfil.id}


class BatchPerfilesRequest(BaseModel):
    perfil_ids: list[str]


class PerfilDetalle(BaseModel):
    lista_seguidores: list[str]
    lista_siguiendo: list[str]


@router.get("/detalle", response_model=PerfilDetalle)
def obtener_detalle_perfil(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta or not cuenta.perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")
    return PerfilDetalle(
        lista_seguidores=cuenta.perfil.lista_seguidores or [],
        lista_siguiendo=cuenta.perfil.lista_siguiendo or [],
    )


@router.post("/por-ids", response_model=list[PerfilBasico])
def obtener_perfiles_por_ids(
    request: BatchPerfilesRequest,
    db: Session = Depends(get_db),
):
    perfiles = db.query(Perfil).filter(Perfil.id.in_(request.perfil_ids)).all()
    return [
        PerfilBasico(
            perfil_id=p.id,
            nombre_usuario=p.nombre_usuario,
            foto_perfil=p.foto_perfil,
        )
        for p in perfiles
    ]
