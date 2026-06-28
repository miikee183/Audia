from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database.database import Base, engine
from app.database.migrate import drop_tables
from app.routes.auth import router as auth_router
from app.routes.personalizacion import router as personalizacion_router
from app.routes.audio import router as audio_router

drop_tables()

app = FastAPI(title="Audia API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(personalizacion_router)
app.include_router(audio_router)


@app.get("/")
def root():
    return {"app": "Audia API", "version": "0.1.0"}

@app.get("/health")
def health():
    return {"status": "ok"}
