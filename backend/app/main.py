
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import routes_defination, routes_news, routes_papunet, routes_sentence_analysis, routes_translation, routes_llm_analysis, routes_writing_practice # New import
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

app.include_router(routes_defination.router)
app.include_router(routes_news.router)
app.include_router(routes_papunet.router)
app.include_router(routes_sentence_analysis.router)
app.include_router(routes_translation.router)
app.include_router(routes_llm_analysis.router)
app.include_router(routes_writing_practice.router) # Include the new router

@app.get("/")
async def root():
    logger.info("Root endpoint accessed.")
    return {"message": "Welcome to SisuHyy Backend!"}

