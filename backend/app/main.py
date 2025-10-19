import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import routes_news, routes_defination, routes_papunet
from app.services.tnpp_lookup import init_nlp

app = FastAPI()

# Configurable CORS origins via ALLOW_ORIGINS (comma-separated), defaults to "*"
raw_origins = os.getenv("ALLOW_ORIGINS", "*")
allow_origins = ["*"] if raw_origins.strip() == "*" else [o.strip() for o in raw_origins.split(",") if o.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(routes_news.router)
app.include_router(routes_defination.router)
app.include_router(routes_papunet.router)

@app.on_event("startup")
def startup_event():
    # Initialize NLP pipeline once at startup (will download if missing)
    init_nlp()
