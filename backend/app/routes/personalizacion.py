from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.models.personalizacion import Perfil
from app.schemas.personalizacion import PerfilRequest
from app.services.auth_service import get_current_account
from typing import Optional

MAX_SIGUIENDO = 3000


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


class UpdatePerfilRequest(BaseModel):
    nombre_usuario: Optional[str] = None
    biografia: Optional[str] = None
    foto_perfil: Optional[str] = None
    cuenta_privada: Optional[bool] = None


@router.put("/me")
def actualizar_perfil(
    request: UpdatePerfilRequest,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta or not cuenta.perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")

    perfil = cuenta.perfil
    if request.nombre_usuario is not None:
        perfil.nombre_usuario = request.nombre_usuario
    if request.biografia is not None:
        perfil.biografia = request.biografia
    if request.foto_perfil is not None:
        perfil.foto_perfil = request.foto_perfil
    if request.cuenta_privada is not None:
        perfil.cuenta_privada = request.cuenta_privada

    db.commit()
    db.refresh(perfil)
    return {"message": "Perfil actualizado con éxito"}


class ToggleFollowResponse(BaseModel):
    siguiendo: bool


@router.post("/toggle-follow/{target_id}", response_model=ToggleFollowResponse)
def toggle_follow(
    target_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta or not cuenta.perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")

    target = db.query(Perfil).filter(Perfil.id == target_id).first()
    if not target:
        raise HTTPException(status_code=404, detail="Perfil objetivo no encontrado")

    if target_id == cuenta.perfil.id:
        raise HTTPException(status_code=400, detail="No puedes seguirte a ti mismo")

    perfil = cuenta.perfil

    if target_id in (perfil.lista_siguiendo or []):
        new_siguiendo = list(perfil.lista_siguiendo or [])
        new_siguiendo.remove(target_id)
        perfil.lista_siguiendo = new_siguiendo
        perfil.num_siguiendo = len(new_siguiendo)

        seguidores_target = list(target.lista_seguidores or [])
        seguidores_target.remove(perfil.id)
        target.lista_seguidores = seguidores_target
        target.num_seguidores = len(seguidores_target)

        db.commit()
        return ToggleFollowResponse(siguiendo=False)

    if len(perfil.lista_siguiendo or []) >= MAX_SIGUIENDO:
        raise HTTPException(
            status_code=400,
            detail=f"No puedes seguir a más de {MAX_SIGUIENDO} personas",
        )

    new_siguiendo = list(perfil.lista_siguiendo or [])
    new_siguiendo.append(target_id)
    perfil.lista_siguiendo = new_siguiendo
    perfil.num_siguiendo = len(new_siguiendo)

    seguidores_target = list(target.lista_seguidores or [])
    seguidores_target.append(perfil.id)
    target.lista_seguidores = seguidores_target
    target.num_seguidores = len(seguidores_target)

    db.commit()
    return ToggleFollowResponse(siguiendo=True)


@router.post("/block/{target_id}")
def toggle_block(
    target_id: str,
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta or not cuenta.perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")

    target = db.query(Perfil).filter(Perfil.id == target_id).first()
    if not target:
        raise HTTPException(status_code=404, detail="Perfil objetivo no encontrado")

    if target_id == cuenta.perfil.id:
        raise HTTPException(status_code=400, detail="No puedes bloquearte a ti mismo")

    perfil = cuenta.perfil
    bloqueados = list(perfil.lista_bloqueados or [])

    if target_id in bloqueados:
        bloqueados.remove(target_id)
        perfil.lista_bloqueados = bloqueados
        db.commit()
        return {"bloqueado": False}
    else:
        bloqueados.append(target_id)
        perfil.lista_bloqueados = bloqueados
        db.commit()
        return {"bloqueado": True}


@router.get("/bloqueados", response_model=list[PerfilBasico])
def obtener_bloqueados(
    db: Session = Depends(get_db),
    account_id: str = Depends(get_current_account),
):
    cuenta = db.query(Cuenta).filter(Cuenta.id == account_id).first()
    if not cuenta or not cuenta.perfil:
        raise HTTPException(status_code=404, detail="Perfil no encontrado")

    bloqueados_ids = cuenta.perfil.lista_bloqueados or []
    if not bloqueados_ids:
        return []

    perfiles = db.query(Perfil).filter(Perfil.id.in_(bloqueados_ids)).all()
    return [
        PerfilBasico(
            perfil_id=p.id,
            nombre_usuario=p.nombre_usuario,
            foto_perfil=p.foto_perfil,
        )
        for p in perfiles
    ]
