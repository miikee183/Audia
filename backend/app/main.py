import traceback
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from app.database.migrate import reset_all_tables
from app.routes.auth import router as auth_router
from app.routes.personalizacion import router as personalizacion_router
from app.routes.audio import router as audio_router

reset_all_tables()

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


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": f"Internal error: {str(exc)}", "traceback": traceback.format_exc()},
    )


@app.get("/")
def root():
    return {"app": "Audia API", "version": "0.1.0"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/reset")
def reset():
    reset_all_tables(force=True)
    return {"message": "Todos los datos han sido eliminados"}
