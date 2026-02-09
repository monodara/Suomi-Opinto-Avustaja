import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import routes_defination, routes_news, routes_papunet
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

app.include_router(routes_defination.router)
app.include_router(routes_news.router)
app.include_router(routes_papunet.router)

@app.get("/")
async def root():
    logger.info("Root endpoint accessed.")
    return {"message": "Welcome to SisuHyy Backend!"}
