from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
from app.services.papunet_scraper import PapunetScraperService
from app.dependencies import get_papunet_scraper_service
import asyncio

router = APIRouter()

@router.get("/papunet-images/{word}")
async def get_papunet_images(
    word: str,
    papunet_service: PapunetScraperService = Depends(get_papunet_scraper_service)
):
    """
    Get images related to the word from the Papunet image library
    """
    if not word or not word.strip():
        raise HTTPException(status_code=400, detail="Word parameter cannot be empty.")
    try:
        images = await asyncio.wait_for(papunet_service.scrape_papunet_images(word), timeout=30.0)
        return JSONResponse(content={"images": images})
    except asyncio.TimeoutError:
        raise HTTPException(status_code=408, detail="Request timeout")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching images: {str(e)}")
