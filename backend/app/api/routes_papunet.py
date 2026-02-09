from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from app.services.papunet_scraper import scrape_papunet_images
import asyncio

router = APIRouter()

@router.get("/papunet-images/{word}")
async def get_papunet_images(word: str):
    """
    Get images related to the word from the Papunet image library
    """
    if not word or not word.strip():
        raise HTTPException(status_code=400, detail="Word parameter cannot be empty.")
    try:
        images = await asyncio.wait_for(scrape_papunet_images(word), timeout=30.0)
        return JSONResponse(content={"images": images})
    except asyncio.TimeoutError:
        raise HTTPException(status_code=408, detail="Request timeout")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching images: {str(e)}")
