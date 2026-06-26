from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database.database import get_db
from app.models.cuenta import Cuenta
from app.models.personalizacion import Personalizacion
from app.schemas.personalizacion import PersonalizacionRequest

router = APIRouter(prefix="/personalizacion", tags=["personalizacion"])

@router.post("/")
def create_personalizacion(request: PersonalizacionRequest, db: Session = Depends(get_db)):
    cuenta = db.query(Cuenta).filter(Cuenta.id == request.cuenta_id).first()
    if not cuenta:
        raise HTTPException(status_code=404, detail="Cuenta no encontrada")
    
    if cuenta.personalizado:
        raise HTTPException(status_code=400, detail="Esta cuenta ya fue personalizada")

    pers = Personalizacion(
        cuenta_id=request.cuenta_id,
        ano_nacimiento=request.ano_nacimiento,
        sexo=request.sexo,
        nombre_usuario=request.nombre_usuario,
        gustos=request.gustos,
        foto_perfil=request.foto_perfil,
        idioma=request.idioma,
    )
    db.add(pers)
    
    # Marcar cuenta como personalizada
    cuenta.personalizado = True
    
    db.commit()
    db.refresh(pers)
    
    return {"message": "Personalización guardada con éxito", "id": pers.id}
